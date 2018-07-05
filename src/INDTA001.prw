#DEFINE STR0199 'WEB SERVICE DE INTEGRAÇÃO'
#DEFINE STR0299 'MÉTODO DE PESQUISA DO CADASTRO DE CLIENTES'
#DEFINE STR0399 'MÉTODO DE PESQUISA DO CADASTRO DE PRODUTOS'
#DEFINE STR0499 'MÉTODO DE PESQUISA DO CADASTRO DE TRANSPORTADORAS'
#DEFINE STR0599 'MÉTODO DE PESQUISA DO CADASTRO DE CONDIÇÕES DE PGAMENTO'
#DEFINE STR0699 'INCLUSÃO PEDIDO DE VENDA'
#DEFINE STR0799 'EXCLUSÃO DE PEDIDO DE VENDA'
#DEFINE STR0899 'MÉTODO DE CONSULTA DE PEDIDO DE VENDA'
#DEFINE STR0999 'LIBERAÇÃO DE PEDIDO DE VENDA'
#DEFINE STR1099 'INCLUSÃO PEDIDO DE COMPRA'
#DEFINE STR1199 ''
#DEFINE STR1299 'MÉTODO DE CONSULTA DE PEDIDO DE COMPRA'

#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'APWEBSRV.CH'

/*/{Protheus.doc} INDTA001
Web Service para integração com protheus
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
/*/
WSSERVICE INDTA001 DESCRIPTION STR0199

	WSDATA EMPRESA       AS STRING  OPTIONAL
	WSDATA FILIAL        AS STRING  OPTIONAL
	WSDATA TYPE_RESPONSE AS INTEGER OPTIONAL
	WSDATA RESPONSE      AS STRING
	WSDATA RESULT_METHOD AS RESULT

	WSMETHOD PESQUISA_CLIENTE DESCRIPTION STR0299
	WSDATA FIELDS_SA1    AS STRING  OPTIONAL
	WSDATA FIELDS_DA0    AS STRING  OPTIONAL
	WSDATA FIELDS_DA1    AS STRING  OPTIONAL
	WSDATA WHERE_SA1     AS STRING  OPTIONAL
	WSDATA WHERE_DA1     AS STRING  OPTIONAL
	WSDATA SEND_DA0      AS INTEGER OPTIONAL

	WSMETHOD PESQUISA_PRODUTO DESCRIPTION STR0399
	WSDATA FIELDS_SB1    AS STRING  OPTIONAL
	WSDATA FIELDS_SB2    AS STRING  OPTIONAL
	WSDATA FIELDS_SG1    AS STRING  OPTIONAL
	WSDATA WHERE_SB1     AS STRING  OPTIONAL
	WSDATA WHERE_SB2     AS STRING  OPTIONAL
	WSDATA WHERE_SG1     AS STRING  OPTIONAL
	WSDATA SEND_SB2      AS INTEGER OPTIONAL
	WSDATA SEND_SG1      AS INTEGER OPTIONAL

	WSMETHOD PESQUISA_TRANSPORTADORA DESCRIPTION STR0499
	WSDATA FIELDS_SA4    AS STRING OPTIONAL
	WSDATA WHERE_SA4     AS STRING OPTIONAL

	WSMETHOD PESQUISA_CONDICAO_PAGTO DESCRIPTION STR0599
	WSDATA FIELDS_SE4    AS STRING OPTIONAL
	WSDATA WHERE_SE4     AS STRING OPTIONAL

	WSMETHOD INCLUI_PEDIDO_VENDA DESCRIPTION STR0699
	WSDATA C5_CLIENTE AS STRING
	WSDATA C5_LOJACLI AS STRING
	WSDATA C5_CONDPAG AS STRING OPTIONAL
	WSDATA C6_ITENS      AS ITENS_VENDA

	WSMETHOD INCLUI_PEDIDO_COMPRA   DESCRIPTION STR1099
	WSDATA C7_FORNECE AS STRING
	WSDATA C7_LOJA    AS STRING
	WSDATA C7_COND    AS STRING OPTIONAL
	WSDATA C7_ITENS   AS ITENS_COMPRA

	WSMETHOD EXCLUI_PEDIDO_VENDA   DESCRIPTION STR0799
	WSMETHOD CONSULTA_PEDIDO_VENDA DESCRIPTION STR0899
	WSMETHOD LIBERA_PEDIDO_VENDA   DESCRIPTION STR0999
	//	WSMETHOD EXCLUI_PEDIDO_COMPRA   DESCRIPTION STR1199
	WSMETHOD CONSULTA_PEDIDO_COMPRA DESCRIPTION STR1299
	WSDATA ORDER_NUMBER AS STRING
	WSDATA TYPE_REQUEST AS INTEGER OPTIONAL
	WSDATA RELEASE_TYPE AS STRING OPTIONAL

ENDWSSERVICE

/*/{Protheus.doc} ITEM_VENDA
Estrura de dados do item de venda
@author Elton Teodoro Alves
@since 26/06/2018
@version 12.1.017
/*/
WSSTRUCT DADOS_ITEM_VENDA

	WSDATA C6_PRODUTO AS STRING
	WSDATA C6_QTDVEN  AS FLOAT
	WSDATA C6_PRCVEN  AS FLOAT  OPTIONAL
	WSDATA C6_TES     AS STRING OPTIONAL

ENDWSSTRUCT

/*/{Protheus.doc} ITEM_VENDA
Estrura de dados do item de venda
@author Elton Teodoro Alves
@since 26/06/2018
@version 12.1.017
/*/
WSSTRUCT ITENS_VENDA

	WSDATA PRODUTOS AS ARRAY OF DADOS_ITEM_VENDA

ENDWSSTRUCT

/*/{Protheus.doc} ITEM_COMPRA
Estrura de dados do item de compra
@author Elton Teodoro Alves
@since 26/06/2018
@version 12.1.017
/*/
WSSTRUCT DADOS_ITEM_COMPRA

	WSDATA C7_PRODUTO AS STRING
	WSDATA C7_QUANT   AS FLOAT
	WSDATA C7_PRECO   AS FLOAT OPTIONAL

ENDWSSTRUCT

/*/{Protheus.doc} ITEM_VENDA
Estrura de dados do item de venda
@author Elton Teodoro Alves
@since 26/06/2018
@version 12.1.017
/*/
WSSTRUCT ITENS_COMPRA

	WSDATA PRODUTOS AS ARRAY OF DADOS_ITEM_COMPRA

ENDWSSTRUCT

/*/{Protheus.doc} RESULT
Estrura de dados do resultado do método
@author Elton Teodoro Alves
@since 26/06/2018
@version 12.1.017
/*/
WSSTRUCT RESULT

	WSDATA RESULT       AS INTEGER
	WSDATA MESSAGE      AS STRING OPTIONAL
	WSDATA ORDER_NUMBER AS STRING OPTIONAL
	WSDATA ORDER_SCHEMA AS STRING OPTIONAL
	WSDATA ORDER_DATA   AS STRING OPTIONAL

ENDWSSTRUCT

/*/{Protheus.doc} CLIENTE
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
WSMETHOD PESQUISA_CLIENTE WSRECEIVE EMPRESA, FILIAL, FIELDS_SA1, FIELDS_DA0, FIELDS_DA1, WHERE_SA1, WHERE_DA1, SEND_DA0, TYPE_RESPONSE WSSEND RESPONSE WSSERVICE INDTA001

	Local oModel     := Nil
	Local oGridSA1   := Nil
	Local oGridDA1   := Nil
	Local oSetEnv    := SetEnv():New()

	Default EMPRESA       := ''
	Default FILIAL        := ''
	Default FIELDS_SA1    := ''
	Default FIELDS_DA0    := ''
	Default FIELDS_DA1    := ''
	Default WHERE_SA1     := ''
	Default WHERE_DA1     := ''
	Default SEND_DA0      := 2
	Default TYPE_RESPONSE := 1

	If ! oSetEnv:Set( EMPRESA, FILIAL )

		::RESPONSE := oSetEnv:ErrorMessage

		Return .T.

	End If

	oModel   := ClienteMod( FIELDS_SA1, FIELDS_DA0, FIELDS_DA1, SEND_DA0 )
	oGridSA1 := oModel:GetModel('SA1-CLIENTES' )

	If SEND_DA0 == 1

		oGridDA1 := oModel:GetModel('DA1-ITENS_LISTA_DE_PRECOS' )

	End If

	oGridSA1:SetLoadFilter( ,DecodeUtf8(WHERE_SA1) )

	If SEND_DA0 == 1

		oGridDA1:SetLoadFilter( ,DecodeUtf8(WHERE_DA1) )

	End If

	oModel:SetOperation( MODEL_OPERATION_VIEW )

	DbSelectArea( 'SA1' )
	DbSetOrder( 1 )
	DbSeek( xFilial('SA1') )

	oModel:Activate()

	If TYPE_RESPONSE # 1

		::RESPONSE := Encode64( oModel:GetXMLData(,,,,.F.,.T.,.F.) )

	Else

		::RESPONSE := Encode64( oModel:GetXMLSchema() )

	End If

	oModel:DeActivate()

Return oSetEnv:Clear()

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

	oStrSA1:SetProperty( '*' , MODEL_FIELD_INIT, Nil )

	SX2->( DbSeek( 'DA0' ) )

	oStrDA0 := FWFormStruct(1,'DA0',{|cCpo| AllTrim(cCpo) $ SX2->X2_UNICO .Or. Empty( FIELDS_DA0 ) .Or. AllTrim(cCpo) $ FIELDS_DA0 })

	oStrDA0:SetProperty( '*' , MODEL_FIELD_INIT, Nil )

	SX2->( DbSeek( 'DA1' ) )

	oStrDA1 := FWFormStruct(1,'DA1',{|cCpo| AllTrim(cCpo) $ SX2->X2_UNICO .Or. Empty( FIELDS_DA1 ) .Or. AllTrim(cCpo) $ FIELDS_DA1 })

	oStrDA1:SetProperty( '*' , MODEL_FIELD_INIT, Nil )

	SX2->( RestArea( aAreaSX2 ) )

	oModel:SetDescription('Modelo de Dados Filial x Clientes x Tabela de Preço x Itens Tabela de Preço')

	oModel:addFields('SM0-FILIAL',,oStrSM0,,,{|oFieldModel, lCopy|LoadSM0(oFieldModel, lCopy, cAlias)})
	oModel:getModel('SM0-FILIAL'):SetDescription('Filial Corrente')

	oModel:addGrid('SA1-CLIENTES','SM0-FILIAL',oStrSA1)
	oModel:getModel('SA1-CLIENTES'):SetDescription('Lista de Clientes ')
	oModel:getModel('SA1-CLIENTES'):SetOptional(.T.)
	oModel:SetRelation('SA1-CLIENTES', { { 'A1_FILIAL', 'M0_CODFIL' } }, SA1->(IndexKey(1)) )

	If SEND_DA0 == 1

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

/*/{Protheus.doc} PRODUTO
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
WSMETHOD PESQUISA_PRODUTO WSRECEIVE EMPRESA, FILIAL, FIELDS_SB1, FIELDS_SB2, FIELDS_SG1, WHERE_SB1, WHERE_SB2, WHERE_SG1, SEND_SB2, SEND_SG1, TYPE_RESPONSE WSSEND RESPONSE WSSERVICE INDTA001

	Local oModel     := Nil
	Local oGridSB1   := Nil
	Local oGridSB2   := Nil
	Local oGridSG1   := Nil
	Local oSetEnv    := SetEnv():New()

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

	If ! oSetEnv:Set( EMPRESA, FILIAL )

		::RESPONSE := oSetEnv:ErrorMessage

		Return .T.

	End If

	oModel   := ProdutoMod( FIELDS_SB1, FIELDS_SB2, FIELDS_SG1, SEND_SB2, SEND_SG1 )
	oGridSB1 := oModel:GetModel('SB1-PRODUTOS' )

	If SEND_SB2 == 1

		oGridSB2 := oModel:GetModel('SB2-SALDOS' )

	End If

	If SEND_SG1 == 1

		oGridSG1 := oModel:GetModel('SG1-ESTRUTURA' )

	End If

	oGridSB1:SetLoadFilter( ,DecodeUtf8(WHERE_SB1) )

	If SEND_SB2 == 1

		oGridSB2:SetLoadFilter( ,DecodeUtf8(WHERE_SB2) )

	End If

	If SEND_SG1 == 1

		oGridSG1:SetLoadFilter( ,DecodeUtf8(WHERE_SG1) )

	End If

	oModel:SetOperation( MODEL_OPERATION_VIEW )

	DbSelectArea( 'SB1' )
	DbSetOrder( 1 )
	DbSeek( xFilial('SB1') )

	oModel:Activate()

	If TYPE_RESPONSE # 1

		::RESPONSE := Encode64( oModel:GetXMLData(,,,,.F.,.T.,.F.) )

	Else

		::RESPONSE := Encode64( oModel:GetXMLSchema() )

	End If

	oModel:DeActivate()

Return oSetEnv:Clear()

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

	oStrSB1:SetProperty( '*' , MODEL_FIELD_INIT, Nil )

	SX2->( DbSeek( 'DA0' ) )

	oStrSB2 := FWFormStruct(1,'SB2',{|cCpo| AllTrim(cCpo) $ SX2->X2_UNICO .Or. Empty( FIELDS_SB2 ) .Or. AllTrim(cCpo) $ FIELDS_SB2 })

	oStrSB2:SetProperty( '*' , MODEL_FIELD_INIT, Nil )

	SX2->( DbSeek( 'DA1' ) )

	oStrSG1 := FWFormStruct(1,'SG1',{|cCpo| AllTrim(cCpo) $ SX2->X2_UNICO .Or. Empty( FIELDS_SG1 ) .Or. AllTrim(cCpo) $ FIELDS_SG1 })

	oStrSG1:SetProperty( '*' , MODEL_FIELD_INIT, Nil )

	SX2->( RestArea( aAreaSX2 ) )

	oModel:SetDescription('Modelo de Dados Filial x Produtos x Saldos Do Produto x Estrutura do Produto')

	oModel:addFields('SM0-FILIAL',,oStrSM0,,,{|oFieldModel, lCopy|LoadSM0(oFieldModel, lCopy, cAlias)})
	oModel:getModel('SM0-FILIAL'):SetDescription('Filial Corrente')

	oModel:addGrid('SB1-PRODUTOS','SM0-FILIAL',oStrSB1)
	oModel:getModel('SB1-PRODUTOS'):SetDescription('Lista de Produtos ')
	oModel:getModel('SB1-PRODUTOS'):SetOptional(.T.)
	oModel:SetRelation('SB1-PRODUTOS', { { 'B1_FILIAL', 'M0_CODFIL' } }, SB1->(IndexKey(1)) )

	If SEND_SB2 == 1

		oModel:addGrid('SB2-SALDOS','SB1-PRODUTOS',oStrSB2)
		oModel:getModel('SB2-SALDOS'):SetDescription('Lista de Saldos')
		oModel:getModel('SB2-SALDOS'):SetOptional(.T.)
		oModel:SetRelation('SB2-SALDOS', { { 'B2_FILIAL', 'xFilial("SB2")' }, { 'B2_COD', 'B1_COD' } }, SB2->(IndexKey(1)) )

	End If

	If SEND_SG1 == 1

		oModel:addGrid('SG1-ESTRUTURA','SB1-PRODUTOS',oStrSG1)
		oModel:getModel('SG1-ESTRUTURA'):SetDescription('Estrutura do Produto')
		oModel:getModel('SG1-ESTRUTURA'):SetOptional(.T.)
		oModel:SetRelation('SG1-ESTRUTURA', { { 'G1_FILIAL', 'xFilial("SG1")' }, { 'G1_COD', 'B1_COD' } }, SG1->(IndexKey(1)) )

	End If

Return oModel

/*/{Protheus.doc} TRANSPORTADORA
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
WSMETHOD PESQUISA_TRANSPORTADORA WSRECEIVE EMPRESA, FILIAL, FIELDS_SA4, WHERE_SA4, TYPE_RESPONSE WSSEND RESPONSE WSSERVICE INDTA001

	Local oModel     := Nil
	Local oGridSA4   := Nil
	Local oSetEnv    := SetEnv():New()

	Default EMPRESA       := ''
	Default FILIAL        := ''
	Default FIELDS_SA4    := ''
	Default WHERE_SA4     := ''
	Default TYPE_RESPONSE := 1

	If ! oSetEnv:Set( EMPRESA, FILIAL )

		::RESPONSE := oSetEnv:ErrorMessage

		Return .T.

	End If

	oModel   := TranspMod( FIELDS_SA4 )
	oGridSA4 := oModel:GetModel('SA4-TRANSPORTADORAS' )

	oGridSA4:SetLoadFilter( ,DecodeUtf8(WHERE_SA4) )

	oModel:SetOperation( MODEL_OPERATION_VIEW )

	DbSelectArea( 'SA4' )
	DbSetOrder( 1 )
	DbSeek( xFilial('SA4') )

	oModel:Activate()

	If TYPE_RESPONSE # 1

		::RESPONSE := Encode64( oModel:GetXMLData(,,,,.F.,.T.,.F.) )

	Else

		::RESPONSE := Encode64( oModel:GetXMLSchema() )

	End If

	oModel:DeActivate()

Return oSetEnv:Clear()

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

	oStrSA4:SetProperty( '*' , MODEL_FIELD_INIT, Nil )

	SX2->( RestArea( aAreaSX2 ) )

	oModel:SetDescription('Modelo de Dados Filial x Transportadora')

	oModel:addFields('SM0-FILIAL',,oStrSM0,,,{|oFieldModel, lCopy|LoadSM0(oFieldModel, lCopy, cAlias)})
	oModel:getModel('SM0-FILIAL'):SetDescription('Filial Corrente')

	oModel:addGrid('SA4-TRANSPORTADORAS','SM0-FILIAL',oStrSA4)
	oModel:getModel('SA4-TRANSPORTADORAS'):SetDescription('Lista de Transportadoras ')
	oModel:getModel('SA4-TRANSPORTADORAS'):SetOptional(.T.)
	oModel:SetRelation('SA4-TRANSPORTADORAS', { { 'A4_FILIAL', 'M0_CODFIL' } }, SA4->(IndexKey(1)) )

Return oModel

/*/{Protheus.doc} CONDICAO_PAGTO
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
WSMETHOD PESQUISA_CONDICAO_PAGTO WSRECEIVE EMPRESA, FILIAL, FIELDS_SE4, WHERE_SE4, TYPE_RESPONSE WSSEND RESPONSE WSSERVICE INDTA001

	Local oModel     := Nil
	Local oGridSE4   := Nil
	Local oSetEnv    := SetEnv():New()

	Default EMPRESA       := ''
	Default FILIAL        := ''
	Default FIELDS_SE4    := ''
	Default WHERE_SE4     := ''
	Default TYPE_RESPONSE := 1

	If ! oSetEnv:Set( EMPRESA, FILIAL )

		::RESPONSE := oSetEnv:ErrorMessage

		Return .T.

	End If

	oModel   := CondPagMod( FIELDS_SE4 )
	oGridSE4 := oModel:GetModel('SE4-CONDICAO_PAGTO' )

	oGridSE4:SetLoadFilter( ,DecodeUtf8(WHERE_SE4) )

	oModel:SetOperation( MODEL_OPERATION_VIEW )

	DbSelectArea( 'SA4' )
	DbSetOrder( 1 )
	DbSeek( xFilial('SA4') )

	oModel:Activate()

	If TYPE_RESPONSE # 1

		::RESPONSE := Encode64( oModel:GetXMLData(,,,,.F.,.T.,.F.) )

	Else

		::RESPONSE := Encode64( oModel:GetXMLSchema() )

	End If

	oModel:DeActivate()

Return oSetEnv:Clear()

/*/{Protheus.doc} TranspMod
Função que monta o Model com os dados da pesquisa de transportadoras
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param FIELDS_SE4, Caracter, Campos a serem retornados da Tabela SE4 – Cond Pagamento
@return Objeto, Objeto com o Modelo de Dados
/*/
Static Function CondPagMod( FIELDS_SE4 )

	Local cAlias  := 'SE4'
	Local oModel  := MPFormModel():New('CONDICAO_PAGTO')
	Local oStrSM0 := GetSM0Str( cAlias )
	Local oStrSE4 := Nil
	Local aAreaSX2:= SX2->( GetArea() )

	SX2->( DbSeek( 'SE4' ) )

	oStrSE4 := FWFormStruct(1,'SE4',{|cCpo| AllTrim(cCpo) $ SX2->X2_UNICO .Or. Empty( FIELDS_SE4 ) .Or. AllTrim(cCpo) $ FIELDS_SE4 })

	oStrSE4:SetProperty( '*' , MODEL_FIELD_INIT, Nil )

	SX2->( RestArea( aAreaSX2 ) )

	oModel:SetDescription('Modelo de Dados Filial x Condição de Pagamento')

	oModel:addFields('SM0-FILIAL',,oStrSM0,,,{|oFieldModel, lCopy|LoadSM0(oFieldModel, lCopy, cAlias)})
	oModel:getModel('SM0-FILIAL'):SetDescription('Filial Corrente')

	oModel:addGrid('SE4-CONDICAO_PAGTO','SM0-FILIAL',oStrSE4)
	oModel:getModel('SE4-CONDICAO_PAGTO'):SetDescription('Lista de Condições de Pagamento')
	oModel:getModel('SE4-CONDICAO_PAGTO'):SetOptional(.T.)
	oModel:SetRelation('SE4-CONDICAO_PAGTO', { { 'E4_FILIAL', 'M0_CODFIL' } }, SE4->(IndexKey(1)) )

Return oModel

/*/{Protheus.doc} CONSULTA_PEDIDO_VENDA
Método do Web Service que retorna o XML com os dados do Pedido de Venda pesquisado.
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param EMPRESA, Caracter, Empresa da Pesquisa
@param FILIAL, Caracter, Filial da Pesquisa
@param ORDER_NUMBER, Caracter, Número do Pedido de Venda da Consulta
@param TYPE_REQUEST, Numerico, Tipo de requisição da pesquisa 1=XML com os dados da pesquisa 2=XSD com o Schema do XML da pesquisa
@return Objeto, Objeto com dados do retorno da operação
/*/
WSMETHOD CONSULTA_PEDIDO_VENDA WSRECEIVE EMPRESA, FILIAL, ORDER_NUMBER, TYPE_REQUEST WSSEND RESULT_METHOD WSSERVICE INDTA001

	Local oModel     := Nil
	Local oSetEnv    := SetEnv():New()

	Default EMPRESA       := ''
	Default FILIAL        := ''
	Default ORDER_NUMBER  := ''
	Default TYPE_REQUEST := 1

	If ! oSetEnv:Set( EMPRESA, FILIAL )

		::RESULT_METHOD:RESULT      := 0
		::RESULT_METHOD:MESSAGE     := oSetEnv:ErrorMessage

		Return .T.

	End If

	oModel := PedVendMod()

	oModel:SetOperation( MODEL_OPERATION_VIEW )

	DbSelectArea( 'SC5' )
	DbSetOrder( 1 )
	DbSeek( xFilial('SC5') + ORDER_NUMBER )

	oModel:Activate()

	If TYPE_REQUEST == 1

		If ! Empty( ORDER_NUMBER ) .And. Found()

			::RESULT_METHOD:RESULT     := 1
			::RESULT_METHOD:MESSAGE    := 'Pedido de Venda Localizado.'
			::RESULT_METHOD:ORDER_DATA := Encode64( oModel:GetXMLData(,,,,.F.,.T.,.F.) )

		Else

			::RESULT_METHOD:RESULT  := 2
			::RESULT_METHOD:MESSAGE := 'Pedido de Venda não Localizado.'

		End If

	Else

		::RESULT_METHOD:RESULT  := 3
		::RESULT_METHOD:MESSAGE := 'Schema XSD do XML do Modelo de Dados do Pedido de Vendas'
		::RESULT_METHOD:ORDER_SCHEMA   := Encode64( oModel:GetXMLSchema() )

	End If

	oModel:DeActivate()

Return oSetEnv:Clear()

/*/{Protheus.doc} PedVendMod
Função que monta o Model com os dados da pesquisa de Pedido de Venda
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@return Objeto, Objeto com o Modelo de Dados
/*/
Static Function PedVendMod()

	Local oModel  := MPFormModel():New('PEDIDO_VENDA')
	Local oStrSC5 := FWFormStruct(1,'SC5')
	Local oStrSC6 := FWFormStruct(1,'SC6')
	Local oStrSC9 := FWFormStruct(1,'SC9')

	oStrSC5:SetProperty( '*' , MODEL_FIELD_INIT, Nil )
	oStrSC6:SetProperty( '*' , MODEL_FIELD_INIT, Nil )
	oStrSC9:SetProperty( '*' , MODEL_FIELD_INIT, Nil )

	oModel:SetDescription('Pedido de Venda')

	oModel:addFields('SC5-CABECALHO',,oStrSC5)
	oModel:getModel('SC5-CABECALHO'):SetDescription('Cabecalho do Pedido de Venda')

	oModel:addGrid('SC6-ITENS','SC5-CABECALHO',oStrSC6)
	oModel:getModel('SC6-ITENS'):SetDescription('Itens do Pedido de Venda')
	oModel:getModel('SC6-ITENS'):SetOptional(.T.)
	oModel:SetRelation('SC6-ITENS', { { 'C6_FILIAL', 'C5_FILIAL' }, { 'C6_NUM', 'C5_NUM' } }, SC6->(IndexKey(1)) )

	oModel:addGrid('SC9-LIBERACOES','SC6-ITENS',oStrSC9)
	oModel:getModel('SC9-LIBERACOES'):SetDescription('Liberações dos Itens do Pedido de Venda')
	oModel:getModel('SC9-LIBERACOES'):SetOptional(.T.)
	oModel:SetRelation('SC9-LIBERACOES', { { 'C9_FILIAL', 'C6_FILIAL' }, { 'C9_PEDIDO', 'C6_NUM' }, { 'C9_SEQUEN', 'C6_ITEM' } }, SC9->(IndexKey(1)) )

Return oModel

/*/{Protheus.doc} INCLUI_PEDIDO_VENDA
Método do Web Service que retorna o XML com os dados do(s) transportadoras(s) pesquisadas.
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param EMPRESA, Caracter, Empresa da Pesquisa
@param FILIAL, Caracter, Filial da Pesquisa
@param C5_CLIENTE, Caracter, Código do Cliente
@param C5_LOJACLI, Caracter, Filial da Pesquisa
@param C5_CONDPAG, Caracter, Condição de Pagamento
@param C6_ITENS, Objeto, Itens do Pedido de Venda
@return Objeto, Objeto com dados do retorno da operação
/*/
WSMETHOD INCLUI_PEDIDO_VENDA WSRECEIVE EMPRESA, FILIAL, C5_CLIENTE, C5_LOJACLI, C5_CONDPAG, C6_ITENS WSSEND RESULT_METHOD WSSERVICE INDTA001

	Local aCabec  := {}
	Local aItens  := {}
	Local aItem   := {}
	Local cPedido := ''
	Local nX      := 0
	Local oSetEnv := SetEnv():New()
	Local aErro   := {}

	Default EMPRESA       := ''
	Default FILIAL        := ''

	Private	lMsErroAuto    := .F.
	Private	lMsHelpAuto    := .T.
	Private	lAutoErrNoFile := .T.

	If ! oSetEnv:Set( EMPRESA, FILIAL )

		::RESULT_METHOD:RESULT      := 0
		::RESULT_METHOD:MESSAGE     := oSetEnv:ErrorMessage

		Return .T.

	End If

	cPedido := GetSXENum( 'SC5', 'C5_NUM' )

	RollBAckSx8()

	aAdd( aCabec, { 'C5_NUM' , cPedido, Nil } )
	aAdd( aCabec, { 'C5_TIPO',     'N', Nil } )

	// Valida Código e Loja do Cliente
	DbSelectArea( 'SA1' )
	DbSetOrder( 1 )
	DbSeek( xFilial('SA1') + PadR( C5_CLIENTE, GetSx3Cache( 'A1_COD', 'X3_TAMANHO' ) ) + PadR( C5_LOJACLI, GetSx3Cache( 'A1_LOJA', 'X3_TAMANHO' ) ) )

	If ! Found()

		::RESULT_METHOD:RESULT  := 2
		::RESULT_METHOD:MESSAGE := 'Código/Loja do cliente não localizado'

		Return oSetEnv:Clear()

	End If

	aAdd( aCabec, { 'C5_CLIENTE', ::C5_CLIENTE, Nil } )
	aAdd( aCabec, { 'C5_LOJACLI', ::C5_LOJACLI, Nil } )

	//Valida condição de pagamento
	If Empty( ::C5_CONDPAG ) .And. Empty( SA1->A1_COND )

		::RESULT_METHOD:RESULT  := 4
		::RESULT_METHOD:MESSAGE := 'Condição de Pagamento não existente no cadastro do cliente'

		Return oSetEnv:Clear()

	ElseIf ! Empty( ::C5_CONDPAG )

		DbSelectArea( 'SE4' )
		DbSetOrder( 1 )
		DbSeek( xFilial('SE4') + ::C5_CONDPAG )

		If ! Found()

			::RESULT_METHOD:RESULT  := 3
			::RESULT_METHOD:MESSAGE := 'Condição de Pagamento informada não localizada ' + ::C5_CONDPAG

			Return oSetEnv:Clear()

		End If

		aAdd( aCabec, { 'C5_CONDPAG', ::C5_CONDPAG, Nil } )

	End If

	For nX := 1 To Len( ::C6_ITENS:PRODUTOS )

		//Valida Código do Produto preenchido
		If Empty( ::C6_ITENS:PRODUTOS[nX]:C6_PRODUTO )

			::RESULT_METHOD:RESULT  := 6
			::RESULT_METHOD:MESSAGE := 'Código do Produto não Informado, item ' + cValtoChar( nX )

			Return oSetEnv:Clear()

		End If

		//Valida código do produto existente
		DbSelectArea( 'SB1' )
		DbSetOrder( 1 )
		DbSeek( xFilial('SB1') + ::C6_ITENS:PRODUTOS[nX]:C6_PRODUTO )

		If ! Found()

			::RESULT_METHOD:RESULT  := 5
			::RESULT_METHOD:MESSAGE := 'Código do Produto não localizado ' + ::C6_ITENS:PRODUTOS[nX]:C6_PRODUTO

			Return oSetEnv:Clear()

		End If

		aAdd( aItem, { 'C6_PRODUTO', ::C6_ITENS:PRODUTOS[nX]:C6_PRODUTO, Nil } )

		//Valida Quantidade
		If ::C6_ITENS:PRODUTOS[nX]:C6_QTDVEN <= 0

			::RESULT_METHOD:RESULT  := 7
			::RESULT_METHOD:MESSAGE := 'Quantidade do produto menor ou igual a que zero ' + ::C6_ITENS:PRODUTOS[nX]:C6_PRODUTO

			Return oSetEnv:Clear()

		End If

		aAdd( aItem, { 'C6_QTDVEN' , ::C6_ITENS:PRODUTOS[nX]:C6_QTDVEN , Nil } )

		//Valida Preço de Venda negativo
		If ValType( ::C6_ITENS:PRODUTOS[nX]:C6_PRCVEN ) # 'U' .And. ::C6_ITENS:PRODUTOS[nX]:C6_PRCVEN < 0

			::RESULT_METHOD:RESULT  := 8
			::RESULT_METHOD:MESSAGE := 'Preço do produto menor que zero ' + ::C6_ITENS:PRODUTOS[nX]:C6_PRODUTO

			Return oSetEnv:Clear()

		End If

		//Valida Preço de Venda se não foi enviado no cadastro do produto e na tabela de preço
		If ValType( ::C6_ITENS:PRODUTOS[nX]:C6_PRCVEN ) # 'U' .And. ::C6_ITENS:PRODUTOS[nX]:C6_PRCVEN > 0

			aAdd( aItem, { 'C6_PRCVEN' , ::C6_ITENS:PRODUTOS[nX]:C6_PRCVEN , Nil } )

		Else

			If ! Empty( SA1->A1_TABELA )

				DbSelectArea( 'DA1' )
				DbSetOrder( 1 ) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO
				DbSeek( xFilial( 'DA1' ) + SA1->A1_TABELA + ::C6_ITENS:PRODUTOS[nX]:C6_PRODUTO )

				If ! Found()

					::RESULT_METHOD:RESULT  := 9
					::RESULT_METHOD:MESSAGE := 'Preço do produto não localizado em seu cadastro ou em tabela de preço vinculada ao cliente ' + ::C6_ITENS:PRODUTOS[nX]:C6_PRODUTO

					Return oSetEnv:Clear()

				End If

			Else

				If SB1->B1_PRV1 == 0

					::RESULT_METHOD:RESULT  := 9
					::RESULT_METHOD:MESSAGE := 'Preço do produto não localizado em seu cadastro ou em tabela de preço vinculada ao cliente ' + ::C6_ITENS:PRODUTOS[nX]:C6_PRODUTO

					Return oSetEnv:Clear()

				End If

			End If

		End If

		//Valida a Tes recebida ou existente no cadastro do Produtos
		If ! Empty( ::C6_ITENS:PRODUTOS[nX]:C6_TES )

			If ! ( ::C6_ITENS:PRODUTOS[nX]:C6_TES != '500' .And. SubStr( ::C6_ITENS:PRODUTOS[nX]:C6_TES, 1, 1 ) $ '56789' )

				::RESULT_METHOD:RESULT  := 12
				::RESULT_METHOD:MESSAGE := 'O Código do Tipo de Saída deve estar entre 5XX e 9XX (exceto o 500) ' + ::C6_ITENS:PRODUTOS[nX]:C6_TES

				Return oSetEnv:Clear()

			End If

			DbSelectAre( 'SF4' )
			DbSetOrder( 1 )
			DbSeek( xFilial( 'SF4' ) + ::C6_ITENS:PRODUTOS[nX]:C6_TES )

			If ! Found(  )

				::RESULT_METHOD:RESULT  := 10
				::RESULT_METHOD:MESSAGE := 'Tipo de Saída não localizada ' + ::C6_ITENS:PRODUTOS[nX]:C6_TES

				Return oSetEnv:Clear()

			End If

			aAdd( aItem, { 'C6_TES', ::C6_ITENS:PRODUTOS[nX]:C6_TES, Nil } )

		Else

			If Empty( SB1->B1_TS )

				::RESULT_METHOD:RESULT  := 11
				::RESULT_METHOD:MESSAGE := 'Tipo de Saída não existente no cadastro do produto ' + ::C6_ITENS:PRODUTOS[nX]:C6_PRODUTO

				Return oSetEnv:Clear()

			End If

		End If

		aAdd( aItens, Aclone( aItem ) )
		aSize( aItem, 0 )

	Next nX

	BEGIN TRANSACTION

		MSExecAuto( { | X, Y, Z | MATA410( X, Y, Z ) }, aCabec, aItens, 3 )

		If lMsErroAuto

			::RESULT_METHOD:RESULT  := 0

			aErro := aClone( GetAutoGRLog() )

			For nX := 1 To Len(aErro)

				::RESULT_METHOD:MESSAGE += _NoTags( aErro[ nX ] ) + Chr(13) + Chr(10)

			Next nX

			DisarmTransaction()

			Return oSetEnv:Clear()

		End If

	END TRANSACTION

	::RESULT_METHOD:RESULT  := 1
	::RESULT_METHOD:ORDER_NUMBER := cPedido
	::RESULT_METHOD:MESSAGE := 'Pedido Incluído'

Return oSetEnv:Clear()

/*/{Protheus.doc} EXCLUI_PEDIDO_VENDA
Método do Web Service que retorna o XML com os dados do(s) transportadoras(s) pesquisadas.
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param EMPRESA, Caracter, Empresa da Pesquisa
@param FILIAL, Caracter, Filial da Pesquisa
@param ORDER_NUMBER, Caracter, Número do Pedido de Venda da Consulta
@return Objeto, Objeto com dados do retorno da operação
/*/
WSMETHOD EXCLUI_PEDIDO_VENDA WSRECEIVE EMPRESA, FILIAL, ORDER_NUMBER WSSEND RESULT_METHOD WSSERVICE INDTA001

	Local aCabec  := {}
	Local aItens  := {}
	Local aItem   := {}
	Local nX      := 0
	Local oSetEnv := SetEnv():New()
	Local aErro   := {}

	Default EMPRESA       := ''
	Default FILIAL        := ''

	Private	lMsErroAuto    := .F.
	Private	lMsHelpAuto    := .T.
	Private	lAutoErrNoFile := .T.

	If ! oSetEnv:Set( EMPRESA, FILIAL )

		::RESULT_METHOD:RESULT      := 0
		::RESULT_METHOD:MESSAGE     := oSetEnv:ErrorMessage

		Return .T.

	End If

	DbSelectArea( 'SC5' )
	DbSetOrder( 1 )
	DbSeek( xFilial( 'SC5' ) + ORDER_NUMBER )

	//Se Pedido existe percorre campos e preenche os array para o execauto
	If ! Found()

		::RESULT_METHOD:RESULT  := 2
		::RESULT_METHOD:MESSAGE += 'Pedido ' + ORDER_NUMBER + ' não Localizado.'

		Return oSetEnv:Clear()

	Else

		//Popula aCabec com dados dos cabeçalhos do Pedido de Venda
		For nX := 1 To FCount()

			aAdd( aCabec, { FieldName( nX ), FieldGet( nX ), Nil } )

		Next nX

		DbSelectArea( 'SC6' )
		DbSetOrder( 1 )
		DbSeek( xFilial( 'SC6' ) + ORDER_NUMBER )

		// Popula aItens com os dados dos itens do pedido de venda
		Do While ! Eof() .And. SC6->( C6_FILIAL + C6_NUM == xFilial( 'SC6' ) + ORDER_NUMBER )

			For nX := 1 To FCount()

				aAdd( aItem, { FieldName( nX ), FieldGet( nX ), Nil } )

			Next nX

			aAdd( aItens, aClone( aItem ) )
			aSize( aItem, 0 )

			DbSkip()

		End Do

		BEGIN TRANSACTION

			MSExecAuto( { | X, Y, Z | MATA410( X, Y, Z ) }, aCabec, aItens, 5 )

			If lMsErroAuto

				::RESULT_METHOD:RESULT  := 2

				aErro := aClone( GetAutoGRLog() )

				For nX := 1 To Len(aErro)

					::RESULT_METHOD:MESSAGE += _NoTags( aErro[ nX ] ) + Chr(13) + Chr(10)

				Next nX

				DisarmTransaction()

				Return oSetEnv:Clear()

			End If

		END TRANSACTION

	End If

	::RESULT_METHOD:RESULT  := 1
	::RESULT_METHOD:MESSAGE := 'Pedido Excluído'

Return oSetEnv:Clear()

/*/{Protheus.doc} LIBERA_PEDIDO_VENDA
Método do Web Service que retorna o XML com os dados do(s) transportadoras(s) pesquisadas.
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param EMPRESA, Caracter, Empresa da Pesquisa
@param FILIAL, Caracter, Filial da Pesquisa
@param ORDER_NUMBER, Caracter, Número do Pedido de Venda da Consulta
@param RELEASE_TYPE, Caracter, Tipo de Liberação
@return Objeto, Objeto com dados do retorno da operação
/*/
WSMETHOD LIBERA_PEDIDO_VENDA WSRECEIVE EMPRESA, FILIAL, ORDER_NUMBER, RELEASE_TYPE WSSEND RESULT_METHOD WSSERVICE INDTA001

	Local aCabec   := {}
	Local aItens   := {}
	Local aItem    := {}
	Local nX       := 0
	Local oSetEnv  := SetEnv():New()
	Local aErro    := {}
	Local lAtuCred := .F.
	Local lAtuEst  := .F.

	Default EMPRESA       := ''
	Default FILIAL        := ''

	Private	lMsErroAuto    := .F.
	Private	lMsHelpAuto    := .T.
	Private	lAutoErrNoFile := .T.

	If ! oSetEnv:Set( EMPRESA, FILIAL )

		::RESULT_METHOD:RESULT      := 0
		::RESULT_METHOD:MESSAGE     := oSetEnv:ErrorMessage

		Return .T.

	End If

	DbSelectArea( 'SC5' )
	DbSetOrder( 1 )
	DbSeek( xFilial( 'SC5' ) + ORDER_NUMBER)

	If ! Found()

		::RESULT_METHOD:RESULT  := 2
		::RESULT_METHOD:MESSAGE := 'Pedido ' + ORDER_NUMBER + ' não Localizado.'

	Else

		// Libera Pedido de Venda
		If 'ORDER' $ RELEASE_TYPE .And. Empty( SC5->C5_LIBEROK )

			//Popula aCabec com dados dos cabeçalhos do Pedido de Venda
			For nX := 1 To FCount()

				aAdd( aCabec, { FieldName( nX ), FieldGet( nX ), Nil } )

			Next nX

			DbSelectArea( 'SC6' )
			DbSetOrder( 1 )
			DbSeek( xFilial( 'SC6' ) + ORDER_NUMBER )

			// Popula aItens com os dados dos itens do pedido de venda
			Do While ! Eof() .And. SC6->( C6_FILIAL + C6_NUM == xFilial( 'SC6' ) + ORDER_NUMBER )

				For nX := 1 To FCount()

					If FieldName( nX ) == 'C6_QTDLIB'

						aAdd( aItem, { 'C6_QTDLIB', SC6->C6_QTDVEN, Nil } )

					ElseIf ! AllTrim( FieldName( nX ) ) $;
					'/C6_SEGUM/C6_IPIDEV/C6_BLQ/C6_LOCALIZ/C6_CODFAB/C6_LOJAFA/C6_TPCONTR/C6_PEDCOM/C6_ALMTERC/C6_VDMOST/C6_CNATREC/'

						aAdd( aItem, { FieldName( nX ), FieldGet( nX ), Nil } )

					End If

				Next nX

				aAdd( aItens, aClone( aItem ) )
				aSize( aItem, 0 )

				DbSkip()

			End Do

			BEGIN TRANSACTION

				MSExecAuto( { | X, Y, Z | MATA410( X, Y, Z ) }, aCabec, aItens, 4 )

				If lMsErroAuto

					::RESULT_METHOD:RESULT  := 2

					aErro := aClone( GetAutoGRLog() )

					For nX := 1 To Len(aErro)

						::RESULT_METHOD:MESSAGE += _NoTags( aErro[ nX ] ) + Chr(13) + Chr(10)

					Next nX

					DisarmTransaction()

					Return oSetEnv:Clear()

				End If

			END TRANSACTION

		End If

		If ( 'CREDIT' $ RELEASE_TYPE .Or. 'STOCK' $ RELEASE_TYPE ) .And. SC5->C5_LIBEROK == 'S'

			lAtuCred := 'CREDIT' $ RELEASE_TYPE
			lAtuEst  := 'STOCK'  $ RELEASE_TYPE

			DbSelectArea( 'SC9' )
			DbSetOrder( 1 )
			DbSeek( xFilial( 'SC9' ) + ORDER_NUMBER )

			Do While !Eof() .And. SC9->( C9_FILIAL + C9_PEDIDO == xFilial( 'SC9' ) + ORDER_NUMBER )

				If ! Empty (SC9->C9_BLCRED) .And. ! lAtuCred .And. lAtuEst

					::RESULT_METHOD:RESULT  := 2
					::RESULT_METHOD:MESSAGE := 'Deve-se liberar o crédito antes de liberar o estoque.'

					Return oSetEnv:Clear()

				Else

					a450Grava( 1, lAtuCred, lAtuEst )

				End If

				DbSkip()

			End Do

		End If

	End If

	::RESULT_METHOD:RESULT  := 1
	::RESULT_METHOD:MESSAGE := 'Pedido Liberado.'

Return oSetEnv:Clear()

/*/{Protheus.doc} CONSULTA_PEDIDO_COMPRA
Método do Web Service que retorna o XML com os dados do Pedido de Compra pesquisado.
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param EMPRESA, Caracter, Empresa da Pesquisa
@param FILIAL, Caracter, Filial da Pesquisa
@param ORDER_NUMBER, Caracter, Número do Pedido de Compra da Consulta
@param TYPE_REQUEST, Numerico, Tipo de requisição da pesquisa 1=XML com os dados da pesquisa 2=XSD com o Schema do XML da pesquisa
@return Objeto, Objeto com dados do retorno da operação
/*/
WSMETHOD CONSULTA_PEDIDO_COMPRA WSRECEIVE EMPRESA, FILIAL, ORDER_NUMBER, TYPE_REQUEST WSSEND RESULT_METHOD WSSERVICE INDTA001

	Local oModel  := Nil
	Local oSetEnv := SetEnv():New()
	Local lFound  := .F.

	Default EMPRESA       := ''
	Default FILIAL        := ''
	Default ORDER_NUMBER  := ''
	Default TYPE_REQUEST := 1

	If ! oSetEnv:Set( EMPRESA, FILIAL )

		::RESULT_METHOD:RESULT      := 0
		::RESULT_METHOD:MESSAGE     := oSetEnv:ErrorMessage

		Return .T.

	End If

	oModel := PedCompMod()

	oModel:SetOperation( MODEL_OPERATION_VIEW )

	DbSelectArea( 'SC7' )
	DbSetOrder( 1 )
	lFound := DbSeek( xFilial('SC7') + ORDER_NUMBER )

	oModel:Activate()

	If TYPE_REQUEST == 1

		If ! Empty( ORDER_NUMBER ) .And. lFound

			::RESULT_METHOD:RESULT     := 1
			::RESULT_METHOD:MESSAGE    := 'Pedido de Compra Localizado.'
			::RESULT_METHOD:ORDER_DATA := Encode64( oModel:GetXMLData(,,,,.F.,.T.,.F.) )

		Else

			::RESULT_METHOD:RESULT  := 2
			::RESULT_METHOD:MESSAGE := 'Pedido de Compra não Localizado.'

		End If

	Else

		::RESULT_METHOD:RESULT  := 3
		::RESULT_METHOD:MESSAGE := 'Schema XSD do XML do Modelo de Dados do Pedido de Compras'
		::RESULT_METHOD:ORDER_SCHEMA   := Encode64( oModel:GetXMLSchema() )

	End If

	oModel:DeActivate()

Return oSetEnv:Clear()

/*/{Protheus.doc} PedCompMod
Função que monta o Model com os dados da pesquisa de Pedido de Compra
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@return Objeto, Objeto com o Modelo de Dados
/*/
Static Function PedCompMod()

	Local oModel    := MPFormModel():New('PEDIDO_COMPRA')
	Local oStrSC7Cb := FWFormStruct(1,'SC7')
	Local oStrSC7It := FWFormStruct(1,'SC7')
	Local oStrSD1   := FWFormStruct(1,'SD1')

	oStrSC7Cb:SetProperty( '*' , MODEL_FIELD_INIT, Nil )
	oStrSC7It:SetProperty( '*' , MODEL_FIELD_INIT, Nil )
	oStrSD1:SetProperty  ( '*' , MODEL_FIELD_INIT, Nil )

	oModel:SetDescription('Pedido de Compra')

	oModel:addFields('SC7-CABECALHO',,oStrSC7Cb)
	oModel:getModel('SC7-CABECALHO'):SetDescription('Cabecalho do Pedido de Compra')
	oModel:SetPrimaryKey({ 'C7_NUM' })

	oModel:addGrid('SC7-ITENS','SC7-CABECALHO',oStrSC7It)
	oModel:getModel('SC7-ITENS'):SetDescription('Itens do Pedido de Compra')
	oModel:getModel('SC7-ITENS'):SetOptional(.T.)
	oModel:SetRelation('SC7-ITENS', { { 'C7_FILIAL', 'C7_FILIAL' }, { 'C7_NUM', 'C7_NUM' } }, SC7->(IndexKey(1)) )

	oModel:addGrid('SD1-ITENS_NOTA_FISCAL','SC7-ITENS',oStrSD1)
	oModel:getModel('SD1-ITENS_NOTA_FISCAL'):SetDescription('Itens da Nota Fiscal de Entrada')
	oModel:getModel('SD1-ITENS_NOTA_FISCAL'):SetOptional(.T.)
	oModel:SetRelation('SD1-ITENS_NOTA_FISCAL', { { 'D1_FILIAL', 'C7_FILIAL' }, { 'D1_PEDIDO', 'C7_NUM' }, { 'D1_ITEMPC', 'C7_ITEM' } }, SD1->(IndexKey(1)) )

Return oModel

/*/{Protheus.doc} INCLUI_PEDIDO_COMPRA
Método de Inclusão de Pedido de Compra
@author Elton Teodoro Alves
@since 11/06/2018
@version 12.1.017
@param EMPRESA, Caracter, Empresa da Pesquisa
@param FILIAL, Caracter, Filial da Pesquisa
@param C7_FORNECE, Caracter, Número do Pedido de Venda da Consulta
@param C7_LOJA, Caracter, Tipo de Liberação
@param C7_COND, Caracter, Condição de Pagamento do Pedido de Compra
@param C7_ITENS, Objeto, Itens do Pedido de Compra
@return Objeto, Objeto com dados do retorno da operação
/*/
WSMETHOD INCLUI_PEDIDO_COMPRA  WSRECEIVE EMPRESA, FILIAL, C7_FORNECE, C7_LOJA, C7_COND, C7_ITENS WSSEND RESULT_METHOD WSSERVICE INDTA001

	Local aCabec  := {}
	Local aItens  := {}
	Local aItem   := {}
	Local cPedido := ''
	Local nX      := 0
	Local oSetEnv := SetEnv():New()
	Local aErro   := {}

	Default EMPRESA       := ''
	Default FILIAL        := ''

	Private	lMsErroAuto    := .F.
	Private	lMsHelpAuto    := .T.
	Private	lAutoErrNoFile := .T.

	If ! oSetEnv:Set( EMPRESA, FILIAL )

		::RESULT_METHOD:RESULT      := 0
		::RESULT_METHOD:MESSAGE     := oSetEnv:ErrorMessage

		Return .T.

	End If

	aAdd( aCabec, { 'C7_EMISSAO', dDataBase     , Nil } )
	aAdd( aCabec, { 'C7_CONTATO', ''            , Nil } )

	// Valida Código e Loja do Fornecedor
	DbSelectArea( 'SA2' )
	DbSetOrder( 1 )
	DbSeek( xFilial('SA2') + PadR( C7_FORNECE, GetSx3Cache( 'A2_COD', 'X3_TAMANHO' ) ) + PadR( C7_LOJA, GetSx3Cache( 'A2_LOJA', 'X3_TAMANHO' ) ) )

	If ! Found()

		::RESULT_METHOD:RESULT  := 2
		::RESULT_METHOD:MESSAGE := 'Código/Loja do fornecedor não localizado'

		Return oSetEnv:Clear()

	End If

	aAdd( aCabec, { 'C7_FORNECE', ::C7_FORNECE, Nil } )
	aAdd( aCabec, { 'C7_LOJA'   , ::C7_LOJA   , Nil } )
	aAdd( aCabec, { 'CT_FILENT' , ::C7_LOJA   , Nil } )

	//Valida condição de pagamento
	If Empty( ::C7_COND ) .And. Empty( SA2->A2_COND )

		::RESULT_METHOD:RESULT  := 4
		::RESULT_METHOD:MESSAGE := 'Condição de Pagamento não existente no cadastro do Fornecedor'

		Return oSetEnv:Clear()

	ElseIf ! Empty( ::C7_COND )

		DbSelectArea( 'SE4' )
		DbSetOrder( 1 )
		DbSeek( xFilial('SE4') + ::C7_COND )

		If ! Found()

			::RESULT_METHOD:RESULT  := 3
			::RESULT_METHOD:MESSAGE := 'Condição de Pagamento informada não localizada ' + ::C7_COND

			Return oSetEnv:Clear()

		End If

	End If

	aAdd( aCabec, { 'C7_COND', ::C7_COND, Nil } )

	For nX := 1 To Len( ::C7_ITENS:PRODUTOS )

		//Valida Código do Produto preenchido
		If Empty( ::C7_ITENS:PRODUTOS[nX]:C7_PRODUTO )

			::RESULT_METHOD:RESULT  := 6
			::RESULT_METHOD:MESSAGE := 'Código do Produto não Informado, item ' + cValtoChar( nX )

			Return oSetEnv:Clear()

		End If

		//Valida código do produto existente
		DbSelectArea( 'SB1' )
		DbSetOrder( 1 )
		DbSeek( xFilial('SB1') + ::C7_ITENS:PRODUTOS[nX]:C7_PRODUTO )

		If ! Found()

			::RESULT_METHOD:RESULT  := 5
			::RESULT_METHOD:MESSAGE := 'Código do Produto não localizado ' + ::C7_ITENS:PRODUTOS[nX]:C7_PRODUTO

			Return oSetEnv:Clear()

		End If

		aAdd( aItem, { 'C7_PRODUTO', ::C7_ITENS:PRODUTOS[nX]:C7_PRODUTO, Nil } )

		//Valida Quantidade
		If ::C7_ITENS:PRODUTOS[nX]:C7_QUANT <= 0

			::RESULT_METHOD:RESULT  := 7
			::RESULT_METHOD:MESSAGE := 'Quantidade do produto menor ou igual a que zero ' + ::C7_ITENS:PRODUTOS[nX]:C7_PRODUTO

			Return oSetEnv:Clear()

		End If

		aAdd( aItem, { 'C7_QUANT' , ::C7_ITENS:PRODUTOS[nX]:C7_QUANT, Nil } )

		//Valida Preço de Compra negativo
		If ValType( ::C7_ITENS:PRODUTOS[nX]:C7_PRECO ) # 'U' .And. ::C7_ITENS:PRODUTOS[nX]:C7_PRECO <= 0

			::RESULT_METHOD:RESULT  := 8
			::RESULT_METHOD:MESSAGE := 'Preço do produto menor ou igual a zero ' + ::C7_ITENS:PRODUTOS[nX]:C7_PRODUTO

			Return oSetEnv:Clear()

		End If

		aAdd( aItem, { 'C7_PRECO' , ::C7_ITENS:PRODUTOS[nX]:C7_PRECO, Nil } )
		aAdd( aItem, { 'C7_TOTAL' , ::C7_ITENS:PRODUTOS[nX]:C7_QUANT * ::C7_ITENS:PRODUTOS[nX]:C7_PRECO, Nil } )

		aAdd( aItens, Aclone( aItem ) )
		aSize( aItem, 0 )

	Next nX

	BEGIN TRANSACTION

		aAdd( aCabec, { 'C7_NUM'    , cPedido := GetNumSC7(.T.), Nil } )

		MSExecAuto( { | W, X, Y, Z | MATA120( W, X, Y, Z ) }, 1, aCabec, aItens, 3 )

		If lMsErroAuto

			::RESULT_METHOD:RESULT  := 0

			aErro := aClone( GetAutoGRLog() )

			For nX := 1 To Len(aErro)

				::RESULT_METHOD:MESSAGE += _NoTags( aErro[ nX ] ) + Chr(13) + Chr(10)

			Next nX

			DisarmTransaction()

			Return oSetEnv:Clear()

		End If

	END TRANSACTION

	::RESULT_METHOD:RESULT  := 1
	::RESULT_METHOD:ORDER_NUMBER := cPedido
	::RESULT_METHOD:MESSAGE := 'Pedido Incluído'

Return oSetEnv:Clear()

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

/*/{Protheus.doc} SetEnv
Classe que controla a abertura do Ambiente
@author Elton Teodoro Alves
@since 21/06/2018
@version 12.1.017
/*/
Class SetEnv

	Data IsPrepInOn
	Data ErrorMessage

	Method New() Constructor
	Method Set()
	Method Clear()

End Class

/*/{Protheus.doc} New
Método Construtor da Classe
@author Elton Teodoro Alves
@since 21/06/2018
@version 12.1.017
@return Objeto, Estância da Classe
/*/
Method New() Class SetEnv

	::IsPrepInOn := Type( 'cEmpAnt' ) # 'U'

Return Self

/*/{Protheus.doc} Set
Método que seta o ambiente
@author Elton Teodoro Alves
@since 21/06/2018
@version 12.1.017
@param cEmp, characters, Empresa do Ambiente
@param cFil, characters, Filaial  do Ambiente
@return Boolean, Indica se o Ambiente foi aberto com sucesso
/*/
Method Set( cEmp, cFil ) Class SetEnv

	Local lRet := .T.

	If ! ::IsPrepInOn

		If Empty( cEmp ) .Or. Empty( cFil )

			::ErrorMessage := "Informe o Código a EMPRESA e da FILIAL para a abertura do ambiente."

			lRet := .F.

		ElseIf ! RpcSetEnv( cEmp, cFil )

			::ErrorMessage := "Não foi possível a abertura do ambiente."

			lRet := .F.

		End If

	End If

Return lRet

/*/{Protheus.doc} Clear
Método que libera o ambiente
@author Elton Teodoro Alves
@since 21/06/2018
@version 12.1.017
/*/
Method Clear() Class SetEnv

	If ! ::IsPrepInOn

		RpcClearEnv()

	End If

Return .T.