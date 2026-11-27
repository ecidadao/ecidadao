# Novas integrações: o que está realmente disponível

Verificação: 26 de novembro de 2026. Investigação só de leitura; não foram enviados dados pessoais nem pedidos de adesão. Nenhuma das integrações propostas abaixo foi ativada.

Atualização de implementação: o percurso assistido Livro Amarelo foi acrescentado ao site em `/livro-amarelo`, com rascunhos de reclamação, elogio e sugestão e encaminhamento para gov.pt. Não submete participações. A ferramenta `prepare_public_service_feedback` está apenas no MCP experimental `/mcp`; o catálogo público dos plugins mantém as seis ferramentas existentes. A [investigação adicional](service-discovery-research.md) verificou pesquisa anónima de serviços e locais no gov.pt, incluindo Rio Tinto; o [pedido de acesso CUSP](cusp-access-request.md) foi enviado à ARTE e aguarda resposta.

## Resultado

O [ia.gov.pt](https://ia.gov.pt/) apresenta iniciativas e recursos de IA; o [AMALIA no Mosaico](https://mosaico.gov.pt/plataformas-comuns/amalia) é um recurso para construir soluções de IA. Não encontrei nesse portal um catálogo de operações transacionais pronto a ligar ao eCidadão.

A descoberta mais útil foi a **API pública do catálogo iAP**. O próprio [catálogo oficial](https://www.iap.gov.pt/web/iap/catalogo) usa estes endpoints, que responderam sem credenciais:

- `GET https://api.iap.gov.pt/publicapi/api/Service/GetByFilter?PageSize=100&PageNumber=1`
- `GET https://api.iap.gov.pt/publicapi/api/Service/GetById?id=69`

A primeira chamada devolveu **63 entradas**, com `totalItems: 63`. Isto confirma acesso aos metadados; não concede acesso às 63 operações. Há serviços de consulta, operações institucionais e adesões a plataformas misturados no catálogo.

O [inventário](iap-catalogue-2026-11-26.json) conserva nomes, entidades e links. Pode ser atualizado com `python3 scripts/discover_iap_services.py`. O script apenas consulta o catálogo, trata paginação e recusa devolver silenciosamente um inventário incompleto.

## Prioridades para o eCidadão

| Prioridade | Capacidade | Evidência / limite | Próximo passo concreto |
|---|---|---|---|
| 1 | Descobrir serviços, balcões, entidades e canais oficiais | O CUSP documenta REST para `/organisation`, `/point-of-care`, `/service` e canais do serviço. Requer chave e adesão; «pública» não significa anónima. | Pedir condições de consumo só de leitura, cobertura, quotas e chave PPR; construir pesquisa «o que preciso / onde / como». |
| 2 | Agendamentos SIGA | O serviço iAP 69 identifica explicitamente SIGA e marcações. A documentação técnica pública não comprova que um integrador privado possa marcar CC no IRN. | Confirmar com ARTE/operador SIGA o contrato atual, entidades e motivos disponíveis, ambiente de testes e elegibilidade. |
| 3 | Reclamações, elogios e sugestões a serviços públicos | Livro Amarelo Eletrónico tem integração para entidades aderentes receberem/tratarem participações. Isso não prova uma API aberta para um cidadão criar uma participação através de terceiros. | Acrescentar um percurso assistido para o portal oficial, distinto das reclamações de consumo; API só com contrato confirmado. |
| 4 | Carta de condução e pontos | Catálogo iAP 10 e 57. As descrições cobrem dados/estado da carta e pontos. | Confirmar acesso delegado ao cidadão, autenticação e âmbito autorizado antes de desenvolver consultas pessoais. |
| 5 | Segurança Social | Catálogo 16–20: beneficiário, rendimentos, situação contributiva, abono e prestações. | Começar por orientação aos serviços oficiais; consultas privadas dependem de adesão e autorização apropriada. |
| 6 | Finanças | Catálogo 2–7 e 45: IRS, faturas, dívida, atividade, património, resumo fiscal e IUC. | Aprofundar percursos assistidos atuais; separar acesso por cidadão de integrações institucionais. |

Fontes: [API CUSP](https://guias.mosaico.gov.pt/plataformas-comuns-da-administracao-publica/catalogo-unico-de-servicos-publicos-cusp/quais-os-pre-requisitos-tecnicos-de-adesao/api-publica-do-cusp), [adesão CUSP](https://guias.mosaico.gov.pt/plataformas-comuns-da-administracao-publica/catalogo-unico-de-servicos-publicos-cusp/qual-o-processo-de-adesao), [SIGA no catálogo](https://www.iap.gov.pt/web/iap/details?id=69), [arquitetura Livro Amarelo](https://guias.mosaico.gov.pt/plataformas-comuns-da-administracao-publica/livro-amarelo-eletronico/como-esta-estruturada-a-plataforma), [adesão Livro Amarelo](https://guias.mosaico.gov.pt/plataformas-comuns-da-administracao-publica/livro-amarelo-eletronico/qual-o-processo-de-adesao). Os restantes serviços estão ligados individualmente no inventário.

## Agendamentos: contrato encontrado, cobertura por confirmar

Consultei a documentação pública de [wsmarcatendimento](https://ticapp.atlassian.net/wiki/spaces/SD/pages/667254785) e a [representação do WSDL](https://gateway2.digital.gov.pt/lapis/MarcAtendimento.html). Há operações de disponibilidade, criação, consulta, alteração e cancelamento. A criação inclui identificação/contactos, assunto/subassunto, serviço e período disponível. A autenticação documentada é IAPAuthorizationSystem.

Duas limitações impedem afirmar «já podemos marcar CC por API»:

1. A documentação identifica a entrada como Central de Marcações, enquanto o catálogo 69 identifica SIGA. Não encontrei uma associação técnica inequívoca entre esse contrato e a atual marcação de CC/IRN. Há campos e operações como `ObterInformacaoSF` que não bastam para inferir cobertura.
2. O endereço no WSDL é `http://agendamentows/marcatendimento.asmx`, um nome interno, não um endpoint público utilizável. Não o contactei. É necessário obter URLs atuais, credenciais, requisitos e ambiente de testes pelo processo de adesão.

A [adesão iAP](https://guias.mosaico.gov.pt/plataformas-comuns-da-administracao-publica/plataforma-de-integracao-pi/qual-o-processo-de-adesao) prevê protocolo entre consumidor, fornecedor e ARTE, conectividade, testes e posterior passagem a produção. Uma documentação visível não substitui esse processo.

O serviço 68 também merece cuidado: o título menciona espera nas Lojas do Cidadão, mas a descrição devolvida é aviso de vez após receber senha. Não demonstra um endpoint de pesquisa nacional de filas. O adapter atual do eCidadão continua baseado nas consultas públicas descritas em [siga-api-research.md](siga-api-research.md).

## CUSP: há um percurso para consumidores

O [serviço 37](https://www.iap.gov.pt/web/iap/details?id=37) identifica a adesão de uma entidade consumidora do antigo CES. Isto reforça a oportunidade de pesquisa de serviços, mas a documentação antiga SOAP/CES e a atual REST/CUSP não devem ser tratadas como o mesmo contrato.

O guia CUSP descreve chave de pré-produção associada ao NIPC, validação funcional e técnica, e depois chave/URLs de produção. O processo geral dirige-se sobretudo a entidades que prestam serviços públicos e mantêm catálogos. A elegibilidade do eCidadão como consumidor privado só de leitura, bem como o universo de dados acessível, continua por confirmar.

Âmbito do pedido técnico enviado, a aguardar resposta:

- Acesso de leitura ao catálogo nacional, pontos de atendimento, horários, coordenadas, serviços e canais.
- Direito de apresentação no site e em respostas MCP, atribuição, cache, atualização e traduções disponíveis.
- Filtros geográficos, paginação, limites, disponibilidade e versionamento do contrato.
- NIPC e condições de adesão aplicáveis ao eCidadão, PPR e critérios para produção.

## Oportunidades que não são APIs abertas para cidadãos

- **Reboques, serviço 59:** a descrição do catálogo inclui consulta por matrícula e registo de entradas/saídas em parques. A documentação [SMS-Reboques](https://ticapp.atlassian.net/wiki/spaces/SD/pages/664633346) associa utilizadores a divisões/parques e exige bearer token. Não é evidência de uma consulta pública anónima para o eCidadão.
- **Livro Amarelo:** a integração documentada é de receção/tratamento pela entidade; o guia permite apresentar ao cidadão uma ligação ao portal. Não confundir com Livro de Reclamações Eletrónico de consumo.
- **Saúde, CC, residência e rendimentos:** existem entradas no catálogo, mas implicam dados pessoais e permissões específicas. Não testar com identificadores de demonstração em serviços reais.
- **Autenticação.gov/CMD:** autenticar alguém não autoriza automaticamente acesso a todas as APIs de organismos públicos.

## Melhorias que não dependem dessas adesões

1. Organizar os percursos por necessidade: renovar CC, alterar morada, resolver assunto fiscal, reportar rua, reclamar de atendimento público.
2. Distinguir claramente consulta pública, rascunho, redirecionamento e operação concluída; só mostrar conclusão com recibo oficial.
3. No SIGA, indicar cobertura do distrito e permitir procurar distritos vizinhos. Um horário sugerido não prova que é o primeiro ou o mais próximo de todos os balcões.
4. Acrescentar o percurso Livro Amarelo com preparação de texto e ligação oficial.
5. Como complemento à deslocação, avaliar avisos meteorológicos do [IPMA](https://api.ipma.pt/), cuja documentação pública lista JSON abertos. É uma integração de informação, não uma operação administrativa; condições de reutilização devem ser confirmadas antes de publicar.

Recomendação: concentrar a próxima integração no **CUSP para descoberta** e abrir em paralelo o processo técnico do **SIGA para marcações**. São as duas capacidades mais próximas do objetivo «resolver o serviço certo, perto de mim».
