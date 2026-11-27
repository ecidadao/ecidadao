# Finanças e Segurança Social: integrações para além da orientação

Investigação de **27/11/2026**, com documentação oficial disponível publicamente nessa data. Este documento é um plano técnico, não uma integração já autorizada. Não foram usados login, credenciais, dados pessoais, pedidos de adesão ou transações. Não houve contacto com entidades nem alteração de infraestrutura. «Não encontrado» significa que a documentação consultada não estabeleceu um contrato utilizável; não prova a inexistência de um serviço interno.

## Decisão proposta

Há três caminhos distintos:

1. **Entregar já funcionalidades locais:** validar ficheiros IRS contra o esquema oficial, ajudar a analisar documentos escolhidos pelo utilizador, preparar pedidos e acompanhar comprovativos importados. Isto produz resultados concretos sem pedir acesso às contas.
2. **Preparar um conector especializado para empresas:** AT/e-Fatura e Segurança Social/PSi têm contratos técnicos publicados, mas exigem habilitação e autenticação próprias. O produto tem de declarar a entidade representada e as operações permitidas.
3. **Investigar adesão institucional para dados pessoais oficiais:** Autenticação.gov, Sistema de Autorizações e iAP permitem integrações reais, condicionadas a protocolo, finalidade, serviço e direitos de acesso. Não oferecer «ligar todas as minhas contas» com CMD.

As bases desta separação são o [catálogo técnico da AT](https://info.portaldasfinancas.gov.pt/pt/apoio_ao_contribuinte/Outras_entidades/Suporte_tecnologico/Paginas/default.aspx), a [FAQ da PSi](https://www.plataformaservicos.seg-social.pt/psi/faqs.html) e a [elegibilidade da PI/iAP](https://mosaico.gov.pt/plataformas-comuns/iap-pi). As prioridades e a arquitetura abaixo são propostas para o eCidadão, não compromissos dessas entidades.

## 1. Capacidades e consumidores

| Necessidade | Canal oficial confirmado | Quem o pode usar / limite | Implementação proposta |
|---|---|---|---|
| Colocar e acompanhar questão fiscal | e-balcão no Portal das Finanças; existe atendimento específico a não residentes sem senha | Utilizador no canal oficial; não foi identificado contrato público de API de tickets | Preparar assunto, texto e lista de anexos; exportar; importar manualmente comprovativo/resposta, sem declarar envio automático |
| Certidões fiscais | Emissão no portal e documento PDF; validação oficial do documento | Titular/representante no canal adequado; validação por terceiro não equivale a emissão | Leitura local do documento e lembrete de validade; ação para validação oficial, sem consulta automática por código |
| IRS Modelo 3 | Importação de ficheiro com formato publicado | Contribuinte ou contabilista, conforme o ato e representação | Validador local de estrutura; depois editor/exportador limitado, com revisão humana e importação no portal |
| IMI e pagamentos fiscais | Notas de cobrança e pagamentos na área autenticada | Titular/representante; não foi confirmado API público para listar ou pagar toda a conta fiscal | Ler nota escolhida pelo utilizador, apresentar prazo e criar lembrete local; pagamento e confirmação no canal oficial |
| Faturas emitidas/adquiridas | Webservice e-Fatura, incluindo consulta | Produtor/integrador e sujeito passivo autenticado; âmbito concreto descrito abaixo | Adaptador de consulta condicionado; não confundir com classificação de despesas pessoais de IRS |
| Prestações sociais | Pedir/consultar prestações e pagamentos no portal, segundo cada prestação | Beneficiário/representante; não foi confirmado API geral para terceiros | Dossier local, documentos necessários e acompanhamento de comprovativos importados |
| Carreira contributiva | Consulta, extrato PDF e pedidos de revisão no portal | Cidadão autenticado; não foi identificado API público de carreira completa para eCidadão | Importar extrato escolhido, comparar períodos, preparar pedido de revisão; não inferir direito a pensão |
| Questões à Segurança Social | e-Clic: registo, consulta e acompanhamento de pedidos | Utilizador no canal oficial; não foi identificado API público de tickets | Preparação/exportação e histórico local marcado como introduzido pelo utilizador |
| Contribuições e trabalhadores de empregadores | PSi: RH, obrigações contributivas, conta-corrente e situação contributiva | Entidades empregadoras e representantes através de software RH | Piloto empresarial separado, condicionado às permissões efetivas |
| Comprovativo IRS, situação contributiva/prestacional | Serviços catalogados na iAP | Entidades aderentes elegíveis, com finalidade e autorização aplicáveis | Piloto institucional de um único comprovativo, após aprovação por serviço |

Fontes dos percursos: [e-balcão](https://info.portaldasfinancas.gov.pt/pt/apoio_ao_contribuinte/Atendimento/ebalcao/Paginas/default.aspx), [certidão de dívida e não dívida](https://info.portaldasfinancas.gov.pt/pt/apoio_ao_contribuinte/Dividas_e_coimas/Dividas/Certidao_de_divida_e_nao_divida/Paginas/default.aspx), [certidões e comprovativos, julho de 2025](https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/Folhetos_informativos/Documents/certidoes_comprovativos.pdf), [IMI/AIMI](https://info.portaldasfinancas.gov.pt/pt/apoio_ao_contribuinte/Cidadaos/Casa_e_propriedades/Imposto_anual/Paginas/default.aspx), [extrato de carreira](https://www.seg-social.pt/ptss/pssd/menu/ajuda/tutoriais/faq-trabalho-carreiracontributiva-obter-extrato-com-registos), [guia de abono de família](https://www.seg-social.pt/documents/10152/16573130/4001_abono_familia_criancas_jov/c85a98df-0b56-4421-8268-05a55c0c0c8c) e [canais de atendimento da Segurança Social](https://www.seg-social.pt/ptss/pssd/menu/ajuda/contactos-canais-atendimento). As integrações de sistemas são detalhadas nas secções seguintes.

## 2. Autoridade Tributária

### IRS: ficheiros oficiais são uma primeira entrega concreta

A [página de formatos para contribuintes/contabilistas](https://info.portaldasfinancas.gov.pt/pt/apoio_ao_contribuinte/Outras_entidades/Suporte_tecnologico/Formato_de_ficheiros/Contribuintes_e_contabilistas_certificados/Paginas/default.aspx) publica `Suporte_Informatico_IRS_2026.zip`, atualizado em 10/03/2026, para Modelo 3 relativo a rendimentos de 2015 e posteriores. A página também tem outros modelos, incluindo Modelo 2 IMI; isso não constitui uma API de consulta de imóveis ou pagamentos.

Foi descarregado apenas o [ZIP oficial do IRS](https://info.portaldasfinancas.gov.pt/pt/apoio_ao_contribuinte/Outras_entidades/Suporte_tecnologico/Formato_de_ficheiros/Contribuintes_e_contabilistas_certificados/Documents/Suporte_Informatico_IRS_2026.zip), sem executar conteúdo. Contém dois XSD, ambos analisáveis como XML:

| Artefacto observado | Identificador |
|---|---|
| ZIP, SHA-256 | `01a63354fc344163ab0e513d15d3e98e224dbc7d9b4c0fb5b3984fe035641762` |
| `Modelo3IRSv2026.xsd`, SHA-256 | `76fba646d0157a25b3a44ec7292ef05cc948f47e0197ecae1082df2b21155e0a` |
| `types.xsd`, SHA-256 | `c78dfc68857fc6a568f32ada18380bae2df9c0148a2a2d8d8c3332c962609904` |
| Elemento raiz / namespace | `Modelo3IRSv2026` / `http://www.dgci.gov.pt/2009/Modelo3IRSv2026` |

O esquema principal inclui `types.xsd`. Proposta: fixar versão e dependências locais, validar sem acesso à rede e apresentar erros por campo. Passar no XSD significa apenas conformidade estrutural; não comprova correção fiscal, aceitação pela AT, entrega ou liquidação. A versão de 2026 não deve ser aplicada automaticamente à campanha de 2027.

### Webservices de negócio e consulta e-Fatura

O [índice AT para produtores/integradores](https://info.portaldasfinancas.gov.pt/pt/apoio_ao_contribuinte/Outras_entidades/Suporte_tecnologico/Paginas/default.aspx) inclui e-Fatura, séries/ATCUD, documentos de transporte, arrendamento, IVA, IRC, IES e outras obrigações. São contratos por domínio; nem o estatuto de contabilista nem a integração de uma dessas operações dão acesso universal à conta do cliente. Certificação de software de faturação e certificado TLS para comunicação são requisitos diferentes; confirmar aplicabilidade por produto/operação, sem impor certificação de faturação a qualquer ferramenta local.

**Consulta de faturas merece um piloto próprio.** O [manual específico e-Fatura v3.0, outubro de 2025](https://info.portaldasfinancas.gov.pt/pt/apoio_ao_contribuinte/Outras_entidades/Suporte_tecnologico/Webservice/e_Fatura/Documents/Comunicacao_dos_elementos_dos_documentos_de_faturacao.pdf), páginas 4 e 58–63, descreve `InvoicesRequest`/`InvoicesResponse`: consulta pelo NIF emitente **ou** adquirente, datas e paginação. São campos mutuamente exclusivos. A operação tem estado de execução e totais de paginação; uma página vazia/erro não permite concluir que não há faturas. O manual enquadra-a em software de faturação e credenciais do sujeito passivo. Não demonstra consulta de toda a área pessoal, submissão de IRS, pagamento de IMI ou classificação de despesas para deduções. Também não fundamenta excluir todos os sujeitos passivos singulares: o âmbito de um produto de consumo pessoal deve ser confirmado com a AT, sem o presumir.

A [página técnica e-Fatura](https://info.portaldasfinancas.gov.pt/pt/apoio_ao_contribuinte/Outras_entidades/Suporte_tecnologico/Webservice/e_Fatura/Paginas/default.aspx) já liga o [WSDL de consulta](https://info.portaldasfinancas.gov.pt/pt/apoio_ao_contribuinte/Outras_entidades/Suporte_tecnologico/Webservice/e_Fatura/Documents/fatshareInvoices.wsdl). O [manual genérico](https://info.portaldasfinancas.gov.pt/pt/apoio_ao_contribuinte/Outras_entidades/Suporte_tecnologico/Webservice/e_Fatura/Documents/Comunicacao_dos_elementos_dos_documentos_de_faturacao_aspetos_gerais.pdf) descreve SOAP, cifra de credenciais, certificados de teste/produção e subutilizador WFA para comunicação; indica a consulta em `https://servicos.portaldasfinancas.gov.pt:725/fatshare/ws/fatshareFaturas`. A cópia textual consultada ainda contém uma nota de WSDL por disponibilizar. Portanto, antes de implementar: reconciliar manual e WSDL atuais e confirmar o perfil mínimo de **consulta**, sem assumir que WFA é um perfil restrito de leitura.

Dependências: registo/habilitação do produtor, certificado de comunicação apropriado, material de teste, autorização do sujeito passivo, gestão de segredos e confirmação de representação. A [FAQ oficial](https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/questoes_frequentes/pages/faqs-00996.aspx) esclarece a adesão e os certificados de teste; estes não substituem autorização para dados reais. O ambiente de testes não foi invocado. Nenhum segredo deve passar pelo chat ou por argumentos MCP públicos.

### Certidões, e-balcão, IMI e pagamentos

Não foi localizado, no conjunto de contratos consultados, um API público de emissão de certidões fiscais para uma app de cidadão, de gestão de tickets e-balcão, de entrega integral de IRS pessoal ou de execução genérica de pagamentos. A consulta de comprovativo IRS via iAP é uma exceção **institucional** descrita adiante, não a entrega de uma declaração.

Uma certidão PDF importada pode estar desatualizada ou ter sido alterada. O resultado local deve dizer `documento_importado`, conservando data do documento separada de data de importação. Nunca apresentar `certidao_validada` sem validação oficial. Para IMI, usar nota de cobrança para um lembrete é diferente de obter uma referência atual da AT. Importar um comprovativo ou receber uma declaração do utilizador não é conciliação oficial de pagamento.

## 3. Segurança Social: portal do cidadão e PSi

### Cidadão

Os [tutoriais públicos](https://www.seg-social.pt/ptss/pssd/menu/ajuda/tutoriais) distinguem consulta/revisão de carreira, prestações, subcontas e serviços de empregadores. A [consulta de carreira](https://www.seg-social.pt/ptss/pssd/menu/ajuda/tutoriais/faq-trabalho-carreiracontributiva-consultar) exige autenticação no portal; a existência de menu não é contrato externo. Proposta independente: normalizar períodos de um extrato importado e assinalar aparentes lacunas para revisão humana. Uma lacuna no documento não prova ausência de contribuições, nem permite determinar automaticamente direitos ou valor de pensão.

Para prestações, começar por um percurso concreto, como abono, em vez de um formulário universal. Distinguir pedido, comprovativo de entrega, decisão e pagamento. O e-Clic pode ser a passagem para questões e anexos; não há evidência suficiente para sincronizar automaticamente todos os pedidos ou mensagens do cidadão.

### PSi: integração real para RH e representação

A [FAQ PSi](https://www.plataformaservicos.seg-social.pt/psi/faqs.html) identifica entidades empregadoras/representantes através de software RH e responde negativamente ao acesso a título individual. Explica ainda o pedido de acesso ao ambiente de Qualidade ao Instituto de Informática. Esse ambiente pode conter cópias de produção: **não o tratar como repositório público de dados sintéticos**. Credenciais válidas não bastam para uma operação sem permissão; a FAQ distingue 401 de 403.

O [catálogo atual](https://www.plataformaservicos.seg-social.pt/psi/servicos.html) publica WSDL/YAML, operações de vínculos/contratos, obrigações contributivas e conta-corrente. Indica consulta de situação contributiva em julho de 2026 e novas operações de valores a pagamento/PDF em outubro de 2026. Não congelar o produto apenas no documento síntese de fevereiro. O [documento síntese, fevereiro de 2026](https://www.plataformaservicos.seg-social.pt/psi/assets/docs/documento_sintese_2026_02.pdf) distingue Qualidade (`extwww.seg-social.pt`, `extservices.seg-social.pt`) e Produção (`app.seg-social.pt`) e assinala operações antigas a descontinuar. Não foram chamadas.

Exemplo concreto: o [Swagger de situação contributiva](https://www.plataformaservicos.seg-social.pt/psi/assets/docs/situacao-contributiva/ascd-rest.yaml) define `POST /ptss/rest/ascd/declaracao/situacao-contributiva`, operação `dscParceiros`, permissão `ASCD-O113`, com `nissSolicitante` e `nissSolicitado`. Devolve situação regularizada e caminho do documento; 403 inclui falta de relação de representação. O contrato regista um pedido e gera documento: **não o classificar como GET puramente passivo** só porque o catálogo usa «Consultar». Um piloto estritamente de leitura deve escolher outra operação ou obter autorização expressa para esta emissão.

O [diagrama oficial 2FA](https://www.plataformaservicos.seg-social.pt/psi/assets/docs/diagrama%202FA%204.pdf) descreve conta principal/subconta: sem 2FA, Basic com credenciais; com 2FA, senha aplicacional Basic temporariamente disponível ou token Bearer criado no portal. Isto não estabelece OAuth delegado por CMD. Proposta: suportar apenas o mecanismo efetivamente habilitado e confirmado no piloto, preferindo token revogável com permissões mínimas; nunca desativar 2FA para integrar. Confirmar validade, revogação, rotação e limites antes de produção.

Um contabilista pode ser representante autorizado, mas a qualidade profissional isolada não substitui a relação de representação exigida pelo serviço. Consultar documentos de pagamento, emitir documento e executar pagamento são ações diferentes; excluir emissão, cancelamento, confirmação de valores e comunicação de remunerações do primeiro piloto de leitura.

## 4. Autenticação delegada, CMD, SCAP e iAP

### O que pode ser delegado

A [integração Autenticação.gov](https://www.autenticacao.gov.pt/integrar-com-o-autenticacao-gov) admite entidades públicas e privadas mediante protocolo com a ARTE, para autenticação, assinatura e atributos profissionais. O [formulário oficial](https://www.autenticacao.gov.pt/web/guest/integracao-entidade) inicia esse processo. Não foi submetido.

O [repositório oficial de documentação](https://github.com/amagovpt/doc-AUTENTICACAO), ligado pela documentação Autenticação.gov, contém SAML, OAuth, atributos e configuração de pré-produção/produção. O [guia OAuth publicado](https://amagovpt.github.io/doc-AUTENTICACAO/OAuth2/Guia%20r%C3%A1pido%20de%20utiliza%C3%A7%C3%A3o%20do%20OAuth2.pdf) descreve **Implicit Grant**, `client_id` e redirect previamente acordados, consentimento de atributos e obtenção assíncrona destes. Não assumir OIDC ou Authorization Code + PKCE sem confirmação atual da ARTE. O guia limita pedidos ao serviço de atributos a um por segundo. Proposta de segurança: exigir correlação `state`, validar retorno e expiração, não guardar tokens em logs/analytics e tratar atributo ainda `null` como pendente. Preferir protocolo e biblioteca revistos para o fluxo aprovado, sem inventar um fluxo incompatível.

Autenticar a pessoa no eCidadão não transfere cookies da AT/SSD nem confere autorização para todos os seus dados. Mesmo quando atributos de outras fontes estão disponíveis, são os atributos e finalidades aprovados, não uma conta geral. SCAP atesta uma qualidade/poder profissional dentro do seu âmbito; assinatura de documento não significa receção ou aceitação por um serviço.

O [Sistema de Autorizações, atualizado em 29/05/2026](https://mosaico.gov.pt/plataformas-comuns/sistema-de-autorizacoes), prevê empresas privadas e AP, gestão de autorizações e utilização com aplicação associada à CMD. Publica custos sob consulta por escalões. É uma via relevante de portabilidade consentida, mas necessita de adesão e integração de dados concretos. Não confundir com o simples login CMD ou com uma procuração ilimitada.

### Serviços iAP identificados

O [catálogo Mosaico](https://guias.mosaico.gov.pt/plataformas-comuns-da-administracao-publica/plataforma-de-integracao-pi/camada-de-negocio/catalogo-de-servicos-de-interoperabilidade) aponta para o catálogo ARTE/Confluence. Os links externos abaixo são fontes oficiais referenciadas pelo Mosaico, não SDK de terceiro.

| Serviço | Evidência pública | O que falta para eCidadão |
|---|---|---|
| `CESPedidoComprovativoIRS` | [Ficha ARTE, 25/09/2025](https://ticapp.atlassian.net/wiki/spaces/SD/pages/90996796): estado e comprovativo de entrega; clientes conhecidos incluem municípios/universidades; WSDL e `IAPAuthorizationSystem` | Elegibilidade, finalidade, contrato e WSDL autorizado; não entrega IRS |
| `temDividaswscriteria` | [Catálogo Mosaico](https://guias.mosaico.gov.pt/plataformas-comuns-da-administracao-publica/plataforma-de-integracao-pi/camada-de-negocio/catalogo-de-servicos-de-interoperabilidade): existência de dívida à AT | Contrato detalhado e autorização; não inferir saldo completo, lista de dívidas ou referências |
| `CESPedidoSituacaoContrib` | [Ficha ARTE, 25/09/2025](https://ticapp.atlassian.net/wiki/spaces/SD/pages/1901657): situação contributiva, WSDL e clientes institucionais | Permissão por finalidade e entidade; não confundir com PSi |
| `CESPedidoSituacaoPrestacionalService` | [Ficha ARTE, 25/09/2025](https://ticapp.atlassian.net/wiki/spaces/SD/pages/660897815): situação prestacional do cidadão | Estrutura autorizada da resposta, cobertura, fundamento e consentimento quando aplicável |
| `obterDadosBeneficiario`, `obterEscalaoAbono`, `CESPedidoRendimentos` | [Catálogo Mosaico](https://guias.mosaico.gov.pt/plataformas-comuns-da-administracao-publica/plataforma-de-integracao-pi/camada-de-negocio/catalogo-de-servicos-de-interoperabilidade) | Validação individual dos contratos; nomes não demonstram acesso à carreira contributiva integral |

Foi encontrada uma inconsistência de navegação: o resumo Mosaico associa a «Situação prestacional» um link `situacaoContributiva`, enquanto a ficha correspondente descreve dívidas. Usar as fichas de serviço específicas e confirmar o WSDL. O link `IAPAuthorizationSystem` consultado devolveu página indisponível; não foi inferido o mecanismo em falta nem tentado acesso autenticado.

A [PI/iAP, atualizada em 24/07/2026](https://mosaico.gov.pt/plataformas-comuns/iap-pi), dirige-se à AP; privados dependem de enquadramento legal. O [formulário de adesão](https://iap.gov.pt/web/iap/formulario-de-adesao) exige protocolo, identificação institucional, base legal, dados, DPO e configuração de comunicação. Os [pré-requisitos técnicos](https://guias.mosaico.gov.pt/plataformas-comuns-da-administracao-publica/plataforma-de-integracao-pi/quais-os-pre-requisitos-tecnicos-de-adesao) descrevem VPN/IPSec ou circuito dedicado, IP público e requisitos de conectividade. São dependências de infraestrutura a confirmar; não se deve prometer ativação só com uma chave API. Alojamento atual do eCidadão não foi alterado nem auditado para estes requisitos.

## 5. Plano de implementação por entregas

As tarefas seguintes podem começar com dados sintéticos e documentação pública. Não autorizam contactos, recolha de credenciais ou transações.

| Entrega | Resultado verificável | Dependências concretas | Critério de conclusão |
|---|---|---|---|
| P0 — registo de capacidades | `Ecidadao.IntegrationCapabilities`: serviço, consumidor, operação, estado de acesso, fontes, data, limites | Catálogo versionado no repositório | Nunca oferecer operação sem contrato/habilitação; separar cidadão, empresa e entidade aderente |
| P1 — validador IRS local | Página/CLI que valida XML 2026 e mostra erros de estrutura | XSD fixados e hashes acima; motor XSD com rede/DTD/entidades externas desativadas | Casos sintéticos válidos/inválidos e ficheiros grandes/maliciosos; zero comunicação à AT |
| P2 — documentos locais | Importar extrato/certidão/nota por ação explícita, extrair campos, rever e exportar resumo/lembrete | Parser PDF isolado, limites, formatos suportados e política explícita de retenção | Identificar documento desconhecido; preservar origem/data; zero alegação de autenticidade ou pagamento confirmado |
| P3 — pedidos preparados | Estender preparação e-balcão e criar e-Clic por assunto, lista de anexos, exportação e comprovativo manual | Taxonomias verificadas; armazenamento local opcional | Estado inicial `draft`; só marcar entrega como informação do utilizador quando não há recibo verificado |
| P4 — conectores simulados | Comportamentos Elixir `AT.InvoiceReader`, `SS.EmployerReader`, `IAP.EvidenceReader`; fetcher injetado | WSDL/YAML públicos; fixtures sintéticas; contratos que faltam marcados como pendentes | Sem rede em CI e sem operações de escrita; testes de isolamento e erros |
| P5 — piloto empresarial | Uma operação de leitura e uma entidade autorizada | Material de teste AT ou acesso Qualidade PSi, representação, segredos, contrato atualizado | Prova do âmbito, reconciliação de completude, revogação e aprovação antes de produção |
| P6 — piloto institucional | Um comprovativo via iAP e autorização aplicável | Entidade jurídica elegível, acordo ARTE/fonte, conectividade, WSDL, ambientes e finalidade | Prova ponta a ponta em ambiente autorizado; não anunciar cobertura geral |

Prioridade recomendada: P0 + P1; depois P2/P3. P4 pode avançar sem acordos, mas não deve apresentar simuladores como integração ativa. P5 e P6 são linhas separadas e não bloqueiam as entregas locais.

### Contratos internos propostos

Cada resultado deve declarar `provider`, `capability`, `actor_kind`, `source_kind` (`public_documentation`, `user_import` ou `official_api`), `source_date`, `checked_at`, `completeness` e `submitted`. Não aceitar URLs, NIF/NISS de terceiros ou identificadores de tenant arbitrários vindos de uma conversa como autorização. Resolver entidade/representação a partir da ligação aprovada; qualquer conector privado fica fora do MCP público anónimo.

Estados mínimos: `draft`, `imported_unverified`, `awaiting_authorization`, `access_not_enabled`, `success`, `partial`, `permission_denied`, `source_unavailable`. Um erro de fonte nunca é «sem dívida», «sem prestações» ou «pago». Autenticação expirada, representação revogada e falta de documento têm resultados diferentes. Leitura HTTP POST não deve ser automaticamente classificada como transação, mas cada contrato tem de ser revisto quanto a efeitos; a emissão de declaração PSi é um exemplo concreto.

Para P1/P2, preferir processamento no dispositivo e sem persistência por omissão. Se o parser necessário exigir servidor, isso é uma mudança explícita de produto a rever antes de receber documentos reais. Em qualquer caso, downloads e logs não devem expor conteúdo fiscal, NIF/NISS, códigos de validação ou tokens. Nenhum dado real foi usado nesta investigação.

## 6. Plano de testes e aceitação

| Camada | Casos necessários | Evidência exigida |
|---|---|---|
| Capacidade/autorização | Cidadão tenta operação de empregador; contabilista sem representação; cliente CMD sem contrato de dados; serviço desativado | Recusa antes de qualquer chamada; nenhuma elevação por dados fornecidos no pedido |
| IRS/XSD | Ano/namespace incorreto, campo obrigatório, valores inválidos, includes fora do pacote, XXE, limite de tamanho | Resultado determinístico sem rede; mensagens sem reproduzir o documento; teste não confunde XSD válido com aceite pela AT |
| PDF/importação | Documento desconhecido, truncado, OCR ambíguo, páginas repetidas, data ausente, URL/QR malicioso | Solicitar revisão; nunca inventar dados; allowlist de destinos e nenhuma navegação automática |
| e-Fatura | SOAP Fault, falha TLS, timeout, estado aplicacional de erro com HTTP 200, paginação incompleta/duplicada, âmbito emitente/adquirente | `partial` quando apropriado; total conferido; nenhum envio/alteração/cancelamento pelo conector de leitura |
| PSi | 401, 403, token expirado/revogado, representação ausente, resposta parcial, documento não pronto, endereço de download não permitido | Falha distinta de resultado vazio; nunca reutilizar autorização entre entidades |
| CMD/iAP | Cancelamento, `state` incorreto, replay, expiração, atributo pendente, autorização recusada/revogada, finalidade errada, callback duplicado | Nenhum dado entregue fora do âmbito aprovado; redigir testes do protocolo escolhido, sem presumir OIDC |
| UI/MCP | PT/EN, acessibilidade, importação cancelada, resposta tardia, erros da fonte, revisão antes de exportar | Estado visível e coerente; nenhum segredo em prompts/analytics; navegação oficial para concluir atos |
| Integração autorizada futura | Certificados, rede, ambientes, versões e limites reais | Execução separada e opt-in; nunca usar contas pessoais/produção no CI |

Durante esta tarefa só foi verificada a leitura dos dois XSD oficiais, estrutura do ZIP e hashes; **não foi validada uma declaração fiscal**, invocado um webservice de negócio, implementado código de produto ou executado teste com dados pessoais. A CI em desenvolvimento pelo coordenador deve continuar independente desta investigação.

## 7. Perguntas para desbloquear integrações, sem enviar ainda

**AT:** o serviço e-Fatura de consulta admite este produto e quais os perfis mínimos para emitente/adquirente? Qual é o contrato canónico atual, procedimento de homologação, certificado necessário e âmbito de sujeitos passivos singulares? Existem contratos externos específicos para certidões, consulta de pagamentos ou e-balcão, e que entidades podem aderir? Confirmar sem inferir a resposta da existência de outras APIs.

**Instituto de Informática:** qual a operação de leitura PSi adequada ao piloto, âmbito de representação/subconta, emissão de token, expiração/revogação, limites e migração do Basic? Como obter um conjunto de teste autorizado sem cópias pessoais de produção? Existe serviço contratável de carreira ou prestações para o caso concreto, fora do catálogo RH?

**ARTE e entidade fornecedora:** é o eCidadão elegível, diretamente ou como fornecedor de uma entidade aderente? Para comprovativo IRS/situação contributiva, quais a base legal, finalidades, atributos, Sistema de Autorizações, custos, ligação de rede, WSDL e ambientes? Qual o protocolo de autenticação recomendado atualmente e como tratar revogação? Acesso ao catálogo público não constitui resposta positiva.

Próximo passo independente: criar issues separadas para P0 e P1 com os critérios acima, fixar cópias/hashes dos esquemas em alteração própria e desenhar a interface local com fixtures sintéticas. Não é necessário aguardar acordos para essa entrega; acesso direto a dados privados continua condicionado ao respetivo contrato e autorização.
