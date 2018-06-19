#DEFINE WS001      'WEB SERVICE DE INTEGRAÇÃO'
#DEFINE CLIENTE001 'MÉTODO DE PESQUISA DO CADASTRO DE CLIENTES'
#DEFINE PRODUTO001 'MÉTODO DE PESQUISA DO CADASTRO DE PRODUTOS'
#DEFINE TRANSP001  'MÉTODO DE PESQUISA DO CADASTRO DE TRANSPORTADORAS' 
#DEFINE CONDPAG001 'MÉTODO DE PESQUISA DO CADASTRO DE CONDIÇÕES DE PGAMENTO'

#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'APWEBSRV.CH'

/*/{Protheus.doc} INDTA001
Web Service para integração com protheus
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
/*/
WSSERVICE INDTA001 DESCRIPTION WS001

	//-- Parâmetros Comuns aos métodos
	WSDATA EMPRESA       AS STRING  OPTIONAL
	WSDATA FILIAL        AS STRING  OPTIONAL
	WSDATA TYPE_RESPONSE AS INTEGER OPTIONAL
	WSDATA RESPONSE      AS STRING 

	//-- Parâmetros CLIENTE 
	WSDATA FIELDS_SA1    AS STRING  OPTIONAL
	WSDATA FIELDS_DA0    AS STRING  OPTIONAL
	WSDATA FIELDS_DA1    AS STRING  OPTIONAL
	WSDATA WHERE_SA1     AS STRING  OPTIONAL
	WSDATA WHERE_DA1     AS STRING  OPTIONAL
	WSDATA SEND_DA0      AS INTEGER OPTIONAL

	//-- Parâmetros PRODUTO
	WSDATA FIELDS_SB1    AS STRING  OPTIONAL
	WSDATA FIELDS_SB2    AS STRING  OPTIONAL
	WSDATA FIELDS_SG1    AS STRING  OPTIONAL
	WSDATA WHERE_SB1     AS STRING  OPTIONAL
	WSDATA WHERE_SB2     AS STRING  OPTIONAL
	WSDATA WHERE_SG1     AS STRING  OPTIONAL
	WSDATA SEND_SB2      AS INTEGER OPTIONAL
	WSDATA SEND_SG1      AS INTEGER OPTIONAL

	//-- Parâmetros TRANSPORTADORA
	WSDATA FIELDS_SA4    AS STRING OPTIONAL
	WSDATA WHERE_SA4     AS STRING OPTIONAL

	//-- Parâmetros CONDICAO_PAGTO 
	WSDATA FIELDS_SE4    AS STRING OPTIONAL
	WSDATA WHERE_SE4     AS STRING OPTIONAL

	WSMETHOD CLIENTE        DESCRIPTION CLIENTE001
	WSMETHOD PRODUTO        DESCRIPTION PRODUTO001
	WSMETHOD TRANSPORTADORA DESCRIPTION TRANSP001
	WSMETHOD CONDICAO_PAGTO DESCRIPTION CONDPAG001

ENDWSSERVICE

/*/{Protheus.doc} MATA030_REQUEST
Método do Web Service que retorna o XML com os dados do(s) cliente(s) pesquisados.
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param EMPRESA, Caracter, Empresa da Pesquisa
@param FILIAL, Caracter, Filial da Pesquisa
@param FIELDS_SA1, Caracter, Campos a serem retornados na pesquisa da tabela SA1-Clientes 
@param FIELDS_DA0, Caracter, Campos a serem retornados na pesquisa da tabela DA0-Tabela de Preço
@param FIELDS_DA1, Caracter, Campos a serem retornados na pesquisa da tabela SA1-Itens da Tabela de Preço
@param WHERE_SA1, Caracter, Filtro em formato SQL a ser aplicado na pesquisa da tabela SA1-Clientes
@param WHERE_DA1, Caracter, Filtro em formato SQL a ser aplicado na pesquisa da tabela DA1-Itens da Tabela de Preços
@param SEND_DA0, Numerico, Indica se envia no XML a tabela de Preço do Cliente 1=Sim 2=Não
@param TYPE_RESPONSE, Numerico, Tipo de retorno da pesquisa 1=XML com os dados da pesquisa 2=XSD com o Schema do XML da pesquisa
@return Caracter, Xml com os dados do(s) cliente(s) ou Schema do Xml
/*/
WSMETHOD CLIENTE WSRECEIVE EMPRESA, FILIAL, FIELDS_SA1, FIELDS_DA0, FIELDS_DA1, WHERE_SA1, WHERE_DA1, SEND_DA0, TYPE_RESPONSE WSSEND RESPONSE WSSERVICE INDTA001

	Local oModel     := Nil 
	Local oGridSA1   := Nil
	Local oGridDA1   := Nil 
	Local lPrepInOn  := Type( 'cEmpAnt' ) # 'U'

	Default EMPRESA       := ''
	Default FILIAL        := ''
	Default FIELDS_SA1    := ''
	Default FIELDS_DA0    := ''
	Default FIELDS_DA1    := ''
	Default WHERE_SA1     := ''
	Default WHERE_DA1     := ''
	Default SEND_DA0      := 2
	Default TYPE_RESPONSE := 1

	If ! lPrepInOn

		If Empty( EMPRESA ) .Or. Empty(FILIAL)

			::RESPONSE := "Informe o Código a EMPRESA e da FILIAL para a abertura do ambiente."

			Return .T.

		ElseIf ! RpcSetEnv( EMPRESA, FILIAL )

			::RESPONSE := "Não foi possível a abertura do ambiente."

			Return .T.

		End If

	End If

	oModel   := ClienteMod( FIELDS_SA1, FIELDS_DA0, FIELDS_DA1, SEND_DA0 )
	oGridSA1 := oModel:GetModel('SA1-CLIENTES' )

	If SEND_DA0 # 2

		oGridDA1 := oModel:GetModel('DA1-ITENS_LISTA_DE_PRECOS' )

	End If


	If ! Empty( WHERE_SA1 ) .AND. TcSqlExec( "SELECT * FROM " + RetSqlName( "SA1" ) + " WHERE " + WHERE_SA1 ) < 0 

		::RESPONSE := TcSqlError()

		Return .T.

	End If

	If SEND_DA0 # 2 .And. ! Empty( WHERE_DA1 ) .AND. TcSqlExec( "SELECT * FROM " + RetSqlName( "DA1" ) + " WHERE " + WHERE_DA1 ) < 0

		::RESPONSE := TcSqlError()

		Return .T.

	End If

	oGridSA1:SetLoadFilter( ,DecodeUtf8(WHERE_SA1) )

	If SEND_DA0 # 2

		oGridDA1:SetLoadFilter( ,DecodeUtf8(WHERE_DA1) )

	End If

	oModel:SetOperation( MODEL_OPERATION_VIEW )

	DbSelectArea( 'SA1' )
	DbSetOrder( 1 )
	DbSeek( xFilial('SA1') )

	oModel:Activate()

	If TYPE_RESPONSE # 2

		::RESPONSE := oModel:GetXMLData(,,,,.F.,.T.,.F.)

	Else

		::RESPONSE := Encode64( oModel:GetXMLSchema() )

	End If

	oModel:DeActivate()

	If ! lPrepInOn

		RpcClearEnv()

	End If

Return .T.

/*/{Protheus.doc} ClientesMd
Função que monta o Model com os dados da pesquisa de clientes
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param FIELDS_SA1, Caracter, Campos a serem retornados na pesquisa da tabela SA1-Clientes 
@param FIELDS_DA0, Caracter, Campos a serem retornados na pesquisa da tabela DA0-Tabela de Preço
@param FIELDS_DA1, Caracter, Campos a serem retornados na pesquisa da tabela SA1-Itens da Tabela de Preço
@param SEND_DA0, Numerico, Indica se envia no XML a tabela de Preço do Cliente 1=Sim/2=Não
@return Objeto, Objeto com o Modelo de Dados
/*/
Static Function ClienteMod( FIELDS_SA1, FIELDS_DA0, FIELDS_DA1, SEND_DA0 )

	Local cAlias  := 'SA1'
	Local oModel  := MPFormModel():New('CLIENTES')
	Local oStrSM0 := GetSM0Str( cAlias )
	Local oStrSA1 := Nil
	Local oStrDA0 := Nil
	Local oStrDA1 := Nil
	Local aAreaSX2:= SX2->( GetArea() )

	SX2->( DbSeek( 'SA1' ) )

	oStrSA1 := FWFormStruct(1,'SA1',{|cCpo| AllTrim(cCpo) $ SX2->X2_UNICO .Or. Empty( FIELDS_SA1 ) .Or. AllTrim(cCpo) $ FIELDS_SA1 + ',A1_TABELA' })

	SX2->( DbSeek( 'DA0' ) )

	oStrDA0 := FWFormStruct(1,'DA0',{|cCpo| AllTrim(cCpo) $ SX2->X2_UNICO .Or. Empty( FIELDS_DA0 ) .Or. AllTrim(cCpo) $ FIELDS_DA0 })

	SX2->( DbSeek( 'DA1' ) )

	oStrDA1 := FWFormStruct(1,'DA1',{|cCpo| AllTrim(cCpo) $ SX2->X2_UNICO .Or. Empty( FIELDS_DA1 ) .Or. AllTrim(cCpo) $ FIELDS_DA1 })

	SX2->( RestArea( aAreaSX2 ) )

	oModel:SetDescription('Modelo de Dados Filial x Clientes x Tabela de Preço x Itens Tabela de Preço')

	oModel:addFields('SM0-FILIAL',,oStrSM0,,,{|oFieldModel, lCopy|LoadSM0(oFieldModel, lCopy, cAlias)})
	oModel:getModel('SM0-FILIAL'):SetDescription('Filial Corrente')

	oModel:addGrid('SA1-CLIENTES','SM0-FILIAL',oStrSA1)
	oModel:getModel('SA1-CLIENTES'):SetDescription('Lista de Clientes ')
	oModel:getModel('SA1-CLIENTES'):SetOptional(.T.)
	oModel:SetRelation('SA1-CLIENTES', { { 'A1_FILIAL', 'M0_CODFIL' } }, SA1->(IndexKey(1)) )

	If SEND_DA0 # 2

		oModel:Addfields('DA0-LISTA_DE_PRECOS','SA1-CLIENTES',oStrDA0)
		oModel:getModel('DA0-LISTA_DE_PRECOS'):SetDescription('Cabeçalho Lista de Preços')
		oModel:getModel('DA0-LISTA_DE_PRECOS'):SetOptional(.T.)
		oModel:SetRelation('DA0-LISTA_DE_PRECOS', { { 'DA0_FILIAL', 'xFilial("DA0")' }, { 'DA0_CODTAB', 'A1_TABELA' } }, DA0->(IndexKey(1)) )

		oModel:addGrid('DA1-ITENS_LISTA_DE_PRECOS','DA0-LISTA_DE_PRECOS',oStrDA1)
		oModel:getModel('DA1-ITENS_LISTA_DE_PRECOS'):SetDescription('Itens da Lista de Preços')
		oModel:getModel('DA1-ITENS_LISTA_DE_PRECOS'):SetOptional(.T.)
		oModel:SetRelation('DA1-ITENS_LISTA_DE_PRECOS', { { 'DA1_FILIAL', 'xFilial("DA1")' }, { 'DA1_CODTAB', 'DA0_CODTAB' } }, DA1->(IndexKey(1)) )

	End If	

Return oModel

/*/{Protheus.doc} MATA030_REQUEST
Método do Web Service que retorna o XML com os dados do(s) produtos(s) pesquisados.
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param EMPRESA, Caracter, Empresa da Pesquisa
@param FILIAL, Caracter, Filial da Pesquisa
@param FIELDS_SB1, Caracter, Campos a serem retornados da Tabela SB1 – Descrição Genérica do Produto
@param FIELDS_SB2, Caracter, Campos a serem retornados da Tabela SB2 – Saldo Físico e Financeiro
@param FIELDS_SG1, Caracter, Campos a serem retornados do cadastro da Tabela SG1 – Estrutura dos Produtos
@param WHERE_SB1, Caracter, Filtro em format SQL aplicado a Grid da Tabela SB1 – Cadastro de Produtos 
@param WHERE_SB2, Caracter, Filtro em format SQL aplicado a Grid da Tabela SB2 – Saldo Físico e Financeiro
@param WHERE_SG1, Caracter, Filtro em format SQL aplicado a Grid da Tabela SG1 – Estrutura dos Produtos
@param SEND_SB2, Numerico, Indica se Retorna na Pesquisa a Tabela SB2 – Saldo Físico e Financeiro: 1=Sim 2=Não
@param SEND_SG1, Numerico,  Indica se Retorna na Pesquisa a Tabela SG1 – Estrutura dos Produtos: 1=Sim 2=Não
@param TYPE_RESPONSE, Numerico, Tipo de retorno da pesquisa 1=XML com os dados da pesquisa 2=XSD com o Schema do XML da pesquisa
@return Caracter, Xml com os dados do(s) produto(s) ou Schema do Xml 
/*/
WSMETHOD PRODUTO WSRECEIVE EMPRESA, FILIAL, FIELDS_SB1, FIELDS_SB2, FIELDS_SG1, WHERE_SB1, WHERE_SB2, WHERE_SG1, SEND_SB2, SEND_SG1, TYPE_RESPONSE WSSEND RESPONSE WSSERVICE INDTA001

	Local oModel     := Nil 
	Local oGridSB1   := Nil
	Local oGridSB2   := Nil
	Local oGridSG1   := Nil
	Local lPrepInOn  := Type( 'cEmpAnt' ) # 'U'

	Default EMPRESA       := ''
	Default FILIAL        := ''
	Default FIELDS_SB1    := ''
	Default FIELDS_SB2    := ''
	Default FIELDS_SG1    := ''
	Default WHERE_SB1     := ''
	Default WHERE_SB2     := ''
	Default WHERE_SG1     := ''
	Default SEND_SB2      := 2
	Default SEND_SG1      := 2
	Default TYPE_RESPONSE := 1

	If ! lPrepInOn

		If Empty( EMPRESA ) .Or. Empty(FILIAL)

			::RESPONSE := "Informe o Código a EMPRESA e da FILIAL para a abertura do ambiente."

			Return .T.

		ElseIf ! RpcSetEnv( EMPRESA, FILIAL )

			::RESPONSE := "Não foi possível a abertura do ambiente."

			Return .T.

		End If

	End If

	oModel   := ProdutoMod( FIELDS_SB1, FIELDS_SB2, FIELDS_SG1, SEND_SB2, SEND_SG1 )
	oGridSB1 := oModel:GetModel('SB1-PRODUTOS' )

	If SEND_SB2 # 2

		oGridSB2 := oModel:GetModel('SB2-SALDOS' )

	End If

	If SEND_SG1 # 2

		oGridSG1 := oModel:GetModel('SG1-ESTRUTURA' )

	End If

	If ! Empty( WHERE_SB1 ) .AND. TcSqlExec( "SELECT * FROM " + RetSqlName( "SB1" ) + " WHERE " + WHERE_SB1 ) < 0 

		::RESPONSE := TcSqlError()

		Return .T.

	End If

	If SEND_SB2 # 2 .And. ! Empty( WHERE_SB2 ) .AND. TcSqlExec( "SELECT * FROM " + RetSqlName( "DA1" ) + " WHERE " + WHERE_SB2 ) < 0

		::RESPONSE := TcSqlError()

		Return .T.

	End If


	If SEND_SG1 # 2 .And. ! Empty( WHERE_SG1 ) .AND. TcSqlExec( "SELECT * FROM " + RetSqlName( "DA1" ) + " WHERE " + WHERE_SG1 ) < 0

		::RESPONSE := TcSqlError()

		Return .T.

	End If

	oGridSB1:SetLoadFilter( ,DecodeUtf8(WHERE_SB1) )

	If SEND_SB2 # 2

		oGridSB2:SetLoadFilter( ,DecodeUtf8(WHERE_SB2) )

	End If

	If SEND_SG1 # 2

		oGridSG1:SetLoadFilter( ,DecodeUtf8(WHERE_SG1) )

	End If

	oModel:SetOperation( MODEL_OPERATION_VIEW )

	DbSelectArea( 'SB1' )
	DbSetOrder( 1 )
	DbSeek( xFilial('SB1') )

	oModel:Activate()

	If TYPE_RESPONSE # 2

		::RESPONSE := oModel:GetXMLData(,,,,.F.,.T.,.F.)

	Else

		::RESPONSE := Encode64( oModel:GetXMLSchema() )

	End If

	oModel:DeActivate()

	If ! lPrepInOn

		RpcClearEnv()

	End If

Return .T.

/*/{Protheus.doc} ProductMod
Função que monta o Model com os dados da pesquisa de produtos
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param FIELDS_SB1, Caracter, Campos a serem retornados da Tabela SB1 – Descrição Genérica do Produto
@param FIELDS_SB2, Caracter, Campos a serem retornados da Tabela SB2 – Saldo Físico e Financeiro
@param FIELDS_SG1, Caracter, Campos a serem retornados do cadastro da Tabela SG1 – Estrutura dos Produtos
@param SEND_SB2, Numerico, Indica se Retorna na Pesquisa a Tabela SB2 – Saldo Físico e Financeiro: 1=Sim 2=Não
@param SEND_SG1, Numerico,  Indica se Retorna na Pesquisa a Tabela SG1 – Estrutura dos Produtos: 1=Sim 2=Não
@return Objeto, Objeto com o Modelo de Dados
/*/
Static Function ProdutoMod( FIELDS_SB1, FIELDS_SB2, FIELDS_SG1, SEND_SB2, SEND_SG1 )

	Local cAlias  := 'SB1'
	Local oModel  := MPFormModel():New('PRODUTOS')
	Local oStrSM0 := GetSM0Str( cAlias )
	Local oStrSB1 := Nil
	Local oStrSB2 := Nil
	Local oStrSG1 := Nil
	Local aAreaSX2:= SX2->( GetArea() )

	SX2->( DbSeek( 'SB1' ) )

	oStrSB1 := FWFormStruct(1,'SB1',{|cCpo| AllTrim(cCpo) $ SX2->X2_UNICO .Or. Empty( FIELDS_SB1 ) .Or. AllTrim(cCpo) $ FIELDS_SB1 })

	SX2->( DbSeek( 'DA0' ) )

	oStrSB2 := FWFormStruct(1,'SB2',{|cCpo| AllTrim(cCpo) $ SX2->X2_UNICO .Or. Empty( FIELDS_SB2 ) .Or. AllTrim(cCpo) $ FIELDS_SB2 })

	SX2->( DbSeek( 'DA1' ) )

	oStrSG1 := FWFormStruct(1,'SG1',{|cCpo| AllTrim(cCpo) $ SX2->X2_UNICO .Or. Empty( FIELDS_SG1 ) .Or. AllTrim(cCpo) $ FIELDS_SG1 })

	SX2->( RestArea( aAreaSX2 ) )

	oModel:SetDescription('Modelo de Dados Filial x Produtos x Saldos Do Produto x Estrutura do Produto')

	oModel:addFields('SM0-FILIAL',,oStrSM0,,,{|oFieldModel, lCopy|LoadSM0(oFieldModel, lCopy, cAlias)})
	oModel:getModel('SM0-FILIAL'):SetDescription('Filial Corrente')

	oModel:addGrid('SB1-PRODUTOS','SM0-FILIAL',oStrSB1)
	oModel:getModel('SB1-PRODUTOS'):SetDescription('Lista de Produtos ')
	oModel:getModel('SB1-PRODUTOS'):SetOptional(.T.)
	oModel:SetRelation('SB1-PRODUTOS', { { 'B1_FILIAL', 'M0_CODFIL' } }, SB1->(IndexKey(1)) )

	If SEND_SB2 # 2

		oModel:addGrid('SB2-SALDOS','SB1-PRODUTOS',oStrSB2)
		oModel:getModel('SB2-SALDOS'):SetDescription('Lista de Saldos')
		oModel:getModel('SB2-SALDOS'):SetOptional(.T.)
		oModel:SetRelation('SB2-SALDOS', { { 'B2_FILIAL', 'xFilial("SB2")' }, { 'B2_COD', 'B1_COD' } }, SB2->(IndexKey(1)) )

	End If

	If SEND_SG1 # 2

		oModel:addGrid('SG1-ESTRUTURA','SB1-PRODUTOS',oStrSG1)
		oModel:getModel('SG1-ESTRUTURA'):SetDescription('Estrutura do Produto')
		oModel:getModel('SG1-ESTRUTURA'):SetOptional(.T.)
		oModel:SetRelation('SG1-ESTRUTURA', { { 'G1_FILIAL', 'xFilial("SG1")' }, { 'G1_COD', 'B1_COD' } }, SG1->(IndexKey(1)) )

	End If	

Return oModel

/*/{Protheus.doc} MATA030_REQUEST
Método do Web Service que retorna o XML com os dados do(s) transportadoras(s) pesquisadas.
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param EMPRESA, Caracter, Empresa da Pesquisa
@param FILIAL, Caracter, Filial da Pesquisa
@param FIELDS_SA4, Caracter, Campos a serem retornados da Tabela SA4 – Transportadoras
@param WHERE_SA4, Caracter, Filtro em format SQL aplicado a Grid da Tabela SA4 – Transportadoras
@param TYPE_RESPONSE, Numerico, Tipo de retorno da pesquisa 1=XML com os dados da pesquisa 2=XSD com o Schema do XML da pesquisa
@return Caracter, Xml com os dados do(s) transportadora(s) ou Schema do Xml 
/*/
WSMETHOD TRANSPORTADORA WSRECEIVE EMPRESA, FILIAL, FIELDS_SA4, WHERE_SA4, TYPE_RESPONSE WSSEND RESPONSE WSSERVICE INDTA001

	Local oModel     := Nil 
	Local oGridSA4   := Nil
	Local lPrepInOn  := Type( 'cEmpAnt' ) # 'U'

	Default EMPRESA       := ''
	Default FILIAL        := ''
	Default FIELDS_SA4    := ''
	Default WHERE_SA4     := ''
	Default TYPE_RESPONSE := 1

	If ! lPrepInOn

		If Empty( EMPRESA ) .Or. Empty(FILIAL)

			::RESPONSE := "Informe o Código a EMPRESA e da FILIAL para a abertura do ambiente."

			Return .T.

		ElseIf ! RpcSetEnv( EMPRESA, FILIAL )

			::RESPONSE := "Não foi possível a abertura do ambiente."

			Return .T.

		End If

	End If

	oModel   := TranspMod( FIELDS_SA4 )
	oGridSA4 := oModel:GetModel('SA4-TRANSPORTADORAS' )

	If ! Empty( WHERE_SA4 ) .AND. TcSqlExec( "SELECT * FROM " + RetSqlName( "SB1" ) + " WHERE " + WHERE_SA4 ) < 0 

		::RESPONSE := TcSqlError()

		Return .T.

	End If

	oGridSA4:SetLoadFilter( ,DecodeUtf8(WHERE_SA4) )

	oModel:SetOperation( MODEL_OPERATION_VIEW )

	DbSelectArea( 'SA4' )
	DbSetOrder( 1 )
	DbSeek( xFilial('SA4') )

	oModel:Activate()

	If TYPE_RESPONSE # 2

		::RESPONSE := oModel:GetXMLData(,,,,.F.,.T.,.F.)

	Else

		::RESPONSE := Encode64( oModel:GetXMLSchema() )

	End If

	oModel:DeActivate()

	If ! lPrepInOn

		RpcClearEnv()

	End If

Return .T.

/*/{Protheus.doc} TranspMod
Função que monta o Model com os dados da pesquisa de transportadoras
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param FIELDS_SA4, Caracter, Campos a serem retornados da Tabela SA4 – Transportadoras
@return Objeto, Objeto com o Modelo de Dados
/*/
Static Function TranspMod( FIELDS_SA4 )

	Local cAlias  := 'SA4'
	Local oModel  := MPFormModel():New('TRANSPORTADORAS')
	Local oStrSM0 := GetSM0Str( cAlias )
	Local oStrSA4 := Nil
	Local aAreaSX2:= SX2->( GetArea() )

	SX2->( DbSeek( 'SA4' ) )

	oStrSA4 := FWFormStruct(1,'SA4',{|cCpo| AllTrim(cCpo) $ SX2->X2_UNICO .Or. Empty( FIELDS_SA4 ) .Or. AllTrim(cCpo) $ FIELDS_SA4 })

	SX2->( RestArea( aAreaSX2 ) )

	oModel:SetDescription('Modelo de Dados Filial x Transportadora')

	oModel:addFields('SM0-FILIAL',,oStrSM0,,,{|oFieldModel, lCopy|LoadSM0(oFieldModel, lCopy, cAlias)})
	oModel:getModel('SM0-FILIAL'):SetDescription('Filial Corrente')

	oModel:addGrid('SA4-TRANSPORTADORAS','SM0-FILIAL',oStrSA4)
	oModel:getModel('SA4-TRANSPORTADORAS'):SetDescription('Lista de Transportadoras ')
	oModel:getModel('SA4-TRANSPORTADORAS'):SetOptional(.T.)
	oModel:SetRelation('SA4-TRANSPORTADORAS', { { 'A4_FILIAL', 'M0_CODFIL' } }, SA4->(IndexKey(1)) )	

Return oModel

/*/{Protheus.doc} MATA030_REQUEST
Método do Web Service que retorna o XML com os dados do(s) transportadoras(s) pesquisadas.
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param EMPRESA, Caracter, Empresa da Pesquisa
@param FILIAL, Caracter, Filial da Pesquisa
@param FIELDS_SE4, Caracter, Campos a serem retornados da Tabela SE4 – Condições de Pagamento
@param WHERE_SE4, Caracter, Filtro em format SQL aplicado a Grid da Tabela SE4 – Condições de Pagamento
@param TYPE_RESPONSE, Numerico, Tipo de retorno da pesquisa 1=XML com os dados da pesquisa 2=XSD com o Schema do XML da pesquisa
@return Caracter, Xml com os dados do(s) condições de pagamento(s) ou Schema do Xml 
/*/
WSMETHOD CONDICAO_PAGTO WSRECEIVE EMPRESA, FILIAL, FIELDS_SE4, WHERE_SE4, TYPE_RESPONSE WSSEND RESPONSE WSSERVICE INDTA001

	Local oModel     := Nil 
	Local oGridSE4   := Nil
	Local lPrepInOn  := Type( 'cEmpAnt' ) # 'U'

	Default EMPRESA       := ''
	Default FILIAL        := ''
	Default FIELDS_SE4    := ''
	Default WHERE_SE4     := ''
	Default TYPE_RESPONSE := 1

	If ! lPrepInOn

		If Empty( EMPRESA ) .Or. Empty(FILIAL)

			::RESPONSE := "Informe o Código a EMPRESA e da FILIAL para a abertura do ambiente."

			Return .T.

		ElseIf ! RpcSetEnv( EMPRESA, FILIAL )

			::RESPONSE := "Não foi possível a abertura do ambiente."

			Return .T.

		End If

	End If

	oModel   := CondPagMod( FIELDS_SE4 )
	oGridSE4 := oModel:GetModel('SE4-CONDICAO_PAGTO' )

	If ! Empty( WHERE_SE4 ) .AND. TcSqlExec( "SELECT * FROM " + RetSqlName( "SB1" ) + " WHERE " + WHERE_SE4 ) < 0 

		::RESPONSE := TcSqlError()

		Return .T.

	End If

	oGridSE4:SetLoadFilter( ,DecodeUtf8(WHERE_SE4) )

	oModel:SetOperation( MODEL_OPERATION_VIEW )

	DbSelectArea( 'SA4' )
	DbSetOrder( 1 )
	DbSeek( xFilial('SA4') )

	oModel:Activate()

	If TYPE_RESPONSE # 2

		::RESPONSE := oModel:GetXMLData(,,,,.F.,.T.,.F.)

	Else

		::RESPONSE := Encode64( oModel:GetXMLSchema() )

	End If

	oModel:DeActivate()

	If ! lPrepInOn

		RpcClearEnv()

	End If

Return .T.

/*/{Protheus.doc} TranspMod
Função que monta o Model com os dados da pesquisa de transportadoras
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param FIELDS_SA4, Caracter, Campos a serem retornados da Tabela SA4 – Transportadoras
@return Objeto, Objeto com o Modelo de Dados
/*/
Static Function CondPagMod( FIELDS_SA4 )

	Local cAlias  := 'SE4'
	Local oModel  := MPFormModel():New('CONDICAO_PAGTO')
	Local oStrSM0 := GetSM0Str( cAlias )
	Local oStrSA4 := Nil
	Local aAreaSX2:= SX2->( GetArea() )

	SX2->( DbSeek( 'SE4' ) )

	oStrSA4 := FWFormStruct(1,'SE4',{|cCpo| AllTrim(cCpo) $ SX2->X2_UNICO .Or. Empty( FIELDS_SE4 ) .Or. AllTrim(cCpo) $ FIELDS_SE4 })

	SX2->( RestArea( aAreaSX2 ) )

	oModel:SetDescription('Modelo de Dados Filial x Condição de Pagamento')

	oModel:addFields('SM0-FILIAL',,oStrSM0,,,{|oFieldModel, lCopy|LoadSM0(oFieldModel, lCopy, cAlias)})
	oModel:getModel('SM0-FILIAL'):SetDescription('Filial Corrente')

	oModel:addGrid('SE4-CONDICAO_PAGTO','SM0-FILIAL',oStrSA4)
	oModel:getModel('SE4-CONDICAO_PAGTO'):SetDescription('Lista de Condições de Pagamento')
	oModel:getModel('SE4-CONDICAO_PAGTO'):SetOptional(.T.)
	oModel:SetRelation('SE4-CONDICAO_PAGTO', { { 'E4_FILIAL', 'M0_CODFIL' } }, SE4->(IndexKey(1)) )	

Return oModel

/*/{Protheus.doc} GetSM0Str
Função que monta a estrutura de campos do model da tabela SM0
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param cAlias, Nome do Alias correspondente 
@return Objeto, Objeto com a estrutura o Modelo de Dados
/*/
Static Function GetSM0Str( cAlias )

	Local oStruct := FWFormModelStruct():New()

	oStruct:AddTable('SM0',{'M0_CODFIL'},'Filial')
	oStruct:AddField('Filial','Filial' , 'M0_CODFIL', 'C', 6, 0, , , {}, .F., , .F., .F., .F., , )
	oStruct:AddIndex( 1, 'FILIAL', 'M0_CODFIL', 'FILIAL', 'FILIAL', '', .F. )

return oStruct

/*/{Protheus.doc} LoadSM0
Função que faz o load do modelo de dados da Filial
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@Param oFieldModel, Objeto, Objeto do Modelo de dados  
@Param lCopy, Booleano, Indica se é uma cópia
@Param cAlias, Caracter, Nome da tabela da pesquisa
@return Array, Array com os dados do Load do Model
/*/
Static Function LoadSM0(oFieldModel, lCopy, cAlias)

	Local aLoad := {}

	aAdd(aLoad, {FwxFilial(cAlias)})
	aAdd(aLoad, 1) 

Return aLoad