# Ordenamento do território e BUPi: capacidades integráveis

Verificação: **27 de novembro de 2026**, por consulta de fontes oficiais e pedidos HTTP GET públicos. Proposta para o eCidadão; nenhuma funcionalidade foi publicada nesta tarefa. Não foram usadas contas, credenciais, identificadores de proprietários, artigos matriciais ou parcelas individuais. Não houve submissões, pedidos de certidão ou contactos externos.

## Decisão proposta

Há três entregas independentes: um guia municipal de PDM/BUPi, um pesquisador de metadados geográficos e uma consulta cartográfica temática limitada. A **OGC API oficial da DGT** é a melhor base técnica nova: tem OpenAPI, descoberta de coleções, metadados, esquemas e consultas públicas verificadas. O **BUPi também publica recursos abertos WMS/WFS e GeoPackage com licença**, mas as tentativas de GetCapabilities devolveram 403 neste ambiente; não anunciar esse conector como operacional.

O produto deve responder «onde consultar o plano e que informação está disponível», não «pode construir aqui» ou «este terreno pertence-lhe». CRUS, cadastro, RGG, registo predial e planos territoriais são objetos diferentes.

## Matriz de capacidades e cobertura

| Capacidade | Fonte e cobertura verificada/documentada | Acesso e formato | Entrega e limite |
|---|---|---|---|
| Identificar município e código administrativo | DGT, coleção `municipios`, CAOP2025 do **Continente**; consulta devolveu `numberMatched=278` | OGC API Features; JSON/GeoJSON, CSV, HTML; leitura anónima verificada | Base de seleção municipal; não assumir Açores/Madeira nesta coleção |
| Descobrir dados e serviços geográficos | DGT, coleção `snig`, `itemType=record`; pesquisa por Maia devolveu 43 registos, 3 solicitados | OGC API Records; metadados JSON, ligação XML CSW por registo | Encontrar fontes, licença e datas; o resultado do catálogo não garante acesso ao conjunto de dados |
| Consultar classes de uso do solo harmonizadas | DGT, `crus`, Portugal continental | OGC API Features e serviço WMS municipal; exemplos GET abaixo | Contexto territorial/estatístico; não determina viabilidade urbanística |
| Descobrir condicionantes | DGT, coleções `srup_ren_areal`, `srup_ren_linear`, `srup_ran`, áreas protegidas, Rede Natura e outras anunciadas em `/collections` | Metadados JSON verificados para REN; Features/Tiles anunciados por coleção | Disponibilidade da coleção não demonstra cobertura completa/atualizada de todos os municípios; cruzar fonte legal e data |
| Consultar IGT, PDM e documentos publicados | SNIT/SGT e geoportais municipais | Aplicações HTML/JavaScript; documentos e serviços OGC conforme cada recurso | Encaminhamento imediato; não foi confirmado contrato de API de processos administrativos do SGT |
| Descobrir cadastro DGT | Coleção `cadastro`, Cadastro Predial — Continente | Metadados públicos; Features e tiles anunciados | Só foram lidos metadados; não se consultaram itens cadastrais nem se demonstrou cobertura parcelar integral |
| Consultar informação BUPi | Mapa Público, consulta pública e conjunto RGG aberto | Visualizador; WMS/WFS e GeoPackage documentados; GET de capacidades recusado com 403 | Guia e links já possíveis; integração de camadas depende de validação operacional |
| Identificar/registar, representar, reclamar | Plataforma BUPi, balcões, conservatória e serviços competentes | Autenticação/legitimidade e documentação; não são operações OGC | Preparar checklist e encaminhar; sem recolha de documentos, autenticação delegada ou submissão pelo eCidadão |

Fontes técnicas: [DGT — dados abertos](https://www.dgterritorio.gov.pt/dados-abertos), [coleções OGC](https://ogcapi.dgterritorio.gov.pt/collections?f=json), [OpenAPI](https://ogcapi.dgterritorio.gov.pt/openapi?f=json), [SNIG — utilização e licenças](https://snig.dgterritorio.gov.pt/perguntas-frequentes). A licença deve ser conferida por coleção/recurso: visualizar no SNIG não equivale a autorização geral para descarregar ou redistribuir.

## Provas técnicas reproduzíveis

Resultados observados em 2026-11-27; não são garantias de disponibilidade futura. Foram usados timeouts de 15–30 segundos e, nos pequenos lotes, concorrência limitada. Não se descarregaram bases cadastrais nem GeoPackages BUPi.

### DGT OGC API

Base: `https://ogcapi.dgterritorio.gov.pt`.

| GET | Resultado observado |
|---|---|
| `/collections?f=json` | 200 JSON; CAOP2025, CRUS, cadastro, COS, ortofotos, SNIG e várias SRUP anunciados |
| `/conformance?f=json` | 200 JSON; anuncia Features, Records, Maps, Tiles, CQL2 e outras classes; anúncio não é teste de todas as operações |
| `/openapi?f=json` | 200; OpenAPI `3.0.2`; para `/collections/crus/items`, `limit` mínimo 1, máximo 100, predefinição 50 |
| `/collections/municipios/queryables?f=json` | 200; campos `dtmn`, `municipio`, `distrito_ilha`, NUTS, área e número de freguesias |
| `/collections/municipios/items?f=json&limit=1&skipGeometry=true` | 200; 1 município devolvido, 278 correspondências, `geometry=null`, paginação por `links[rel=next]` |
| `/collections/snig/items?f=json&limit=3&q=Maia` | 200; 3 de 43 registos; `title`, `description`, `rights`, data e ligações XML; metadados municipais incluíam `otherRestrictions` |
| `/collections/crus/queryables?f=json` | 200; `municipio`, `designacao_no_plano`, `classe_2021`, `categoria_2021`, `escala_origem`, `data_pub_origem`, `registo_ou_deposito`, `situacao_pdm` |
| `/collections/crus/items?f=json&limit=1&skipGeometry=true` | 200; 1 zona temática, sem geometria, 236311 correspondências; não é uma parcela cadastral |
| `/collections/srup_ren_areal?f=json` | 200; metadados, ligações de esquema, consulta e tiles |
| `/collections/cadastro?f=json` | 200; apenas metadados; não foi chamado `/items` |

Exemplos que podem ser repetidos sem identificação de pessoas:

```sh
curl --fail --max-time 20 'https://ogcapi.dgterritorio.gov.pt/collections?f=json'
curl --fail --max-time 20 'https://ogcapi.dgterritorio.gov.pt/collections/municipios/items?f=json&limit=1&skipGeometry=true'
curl --fail --max-time 20 'https://ogcapi.dgterritorio.gov.pt/collections/snig/items?f=json&limit=3&q=Maia'
curl --fail --max-time 20 'https://ogcapi.dgterritorio.gov.pt/collections/crus/queryables?f=json'
```

**Falhas a preservar no desenho:** pedidos com `municipio=Gondomar`, `municipio=Maia` e pesquisas compostas no catálogo devolveram 503; a consulta simples `q=Maia` funcionou. Não ficou demonstrado que filtragem municipal por igualdade funciona neste ambiente. Não converter falhas em «zero resultados» nem anunciar cobertura municipal de CRUS a partir destas tentativas. O esquema anuncia campos consultáveis, mas isso não substitui o teste de cada filtro.

As coleções consultadas anunciam CRS84, EPSG:4326/3857/4258/3763, com armazenamento em EPSG:3763. Confirmar o CRS da resposta e a ordem dos eixos; não trocar coordenadas de WMS 1.3.0 com longitude/latitude GeoJSON. Há metadados temporais que exigem cautela: `municipios` tem título CAOP2025 mas intervalo temporal 2000–2007 no descritor observado. Exibir versão declarada e data de consulta separadamente; não apresentar esse intervalo como atualização do conteúdo.

### WMS/WFS da CRUS — exemplo Maia

Os endereços vêm do [registo oficial CRUS Maia no dados.gov](https://dados.gov.pt/api/1/datasets/carta-do-regime-de-uso-do-solo-maia/), que declara `cc-by`:

- [WMS GetCapabilities](https://servicos.dgterritorio.pt/SDISNITWMSCRUS_1306_1/WMService.aspx?service=WMS&request=getcapabilities): **200 XML**, WMS 1.3.0, título `CRUS - MAIA`; camada agregada `CRUS_Municipal` e classes de solo. Anuncia PNG/JPEG/SVG para mapa e XML/HTML/GML para informação.
- [WFS GetCapabilities](https://servicos.dgterritorio.pt/SDISNITWFSCRUS_1306_1/WFService.aspx?service=WFS&request=getcapabilities): **500**. Não considerar esta via alternativa operacional por existir no catálogo.

Foi ainda executado o seguinte GET, com uma extensão ampla da Maia, sem referência a propriedade individual:

```sh
curl --fail --max-time 20 'https://servicos.dgterritorio.pt/SDISNITWMSCRUS_1306_1/WMService.aspx?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&LAYERS=CRUS_Municipal&STYLES=&CRS=EPSG:4326&BBOX=41.17,-8.71,41.30,-8.49&WIDTH=256&HEIGHT=256&FORMAT=image/png'
```

Resultado: **200 `image/png`, 2303 bytes, assinatura PNG válida**. Prova de resposta raster, não inspeção visual da exatidão da camada; falta verificar legenda e apresentação no cliente. A bbox usa latitude/longitude, conforme WMS 1.3.0 com EPSG:4326.

O WMS aceita, segundo as capacidades, EPSG:4326, 4258, 3763, 3857 e sistemas locais históricos. Para o piloto, manter uma seleção explícita de serviços/camadas e validar respostas OGC, incluindo exceções XML devolvidas com HTTP 200. Nunca aceitar um URL arbitrário do utilizador como origem do servidor.

### BUPi: dados abertos existem, acesso operacional ainda não validado

O [conjunto RGG publicado pela eBUPi](https://dados.gov.pt/pt/datasets/representacao-grafica-georreferenciada) declara **CC BY 4.0**, atualização diária de WMS/WFS e quinzenal de GeoPackage. A [ficha JSON](https://dados.gov.pt/api/1/datasets/representacao-grafica-georreferenciada/) respondeu 200, com alteração em **2026-11-23**, recursos separados para Continente e Madeira e ficheiros datados de 2026-11-16. Açores não ficaram demonstrados neste conjunto.

| Recurso publicado | Endereço base | Verificação |
|---|---|---|
| Continente WMS | `https://geo.bupi.gov.pt/gisbupi/services/opendata/RGG_DadosGovPT/MapServer/WMSServer` | GET com `service=WMS&request=GetCapabilities&version=1.3.0`: 403 |
| Continente WFS | `https://geo.bupi.gov.pt/gisbupi/services/opendata/RGG_DadosGovPT/MapServer/WFSServer` | GET com `service=WFS&request=GetCapabilities&version=2.0.0`: 403 |
| Madeira WMS/WFS | `https://geo.bupi.gov.pt/arcgis/services/opendata/RGG_DadosGovPT_Madeira/MapServer/WMSServer` e `WFSServer` | Documentados na ficha; não testados |
| GeoPackage ZIP | Ligações versionadas na ficha JSON, separadas por território | Só metadados; não descarregados |

O 403 não prova que o serviço exige conta: pode resultar de política de acesso/rede. Não houve tentativa de contornar a recusa. O teste correto futuro é GetCapabilities, nunca uma consulta nacional de parcelas. A ficha recomenda aproximar a área antes de carregar WFS e refere escala inferior a 1:5000; não interpretar essa formulação ambígua como limite contratual de pedidos. A periodicidade declarada também não garante que cada RGG esteja validada ou integrada na carta cadastral.

## PDM, condicionantes e validade da informação

O [SNIT](https://www.dgterritorio.gov.pt/atividades/ordenamento/snit) disponibiliza os instrumentos registados/depositados e as peças gráficas ligadas à publicação oficial. Entradas úteis: [IGT e REN](https://snit-sgt.dgterritorio.gov.pt/), [Geoportal SNIT](https://snit-mais.dgterritorio.gov.pt/PortalSNIT/), [planta de localização](https://snit-mais.dgterritorio.gov.pt/PortalSNITLoc/) e [procedimentos em curso na PCGT](https://pcgt.dgterritorio.gov.pt/lista-procedimentos). O SGT apresentou uma aplicação dependente de JavaScript; não foi descoberta/validada API pública de pesquisa de processos. PCGT/SSAIGT não devem ser confundidos com serviços públicos de edição ou submissão em nome do cidadão.

Dois limites explícitos são decisivos:

- A [DGT sobre CRUS](https://www.dgterritorio.gov.pt/atividades/ordenamento/crus) explica que harmoniza classes dos PDM para análise territorial/estatística e **não pode ser usada para licenciamento ou determinação da conformidade entre atividades e uso do solo**. COS descreve ocupação do solo; não é uma alternativa ao regime urbanístico.
- A [DGT sobre SRUP/REN](https://www.dgterritorio.gov.pt/atividades/ordenamento/sgt/srup) exige confirmação do vetor REN com as imagens publicadas em Diário da República; em caso de dúvida prevalecem os limites das cartas publicadas. «Não encontrado na camada» não significa «sem condicionantes».

Modelo proposto para cada plano: `municipality_code`, `instrument_type`, `title`, `publication_url`, `publication_date`, `effective_date` quando confirmada, `amendments`, `suspensions`, `source_checked_at`, `status=unverified|in_force|under_revision`. Uma proposta em discussão pública e uma revisão publicada não são o mesmo estado. Só afirmar vigência após reconciliação das publicações, alterações e suspensões; nesta ronda não foi feita essa auditoria jurídica integral dos três municípios.

## Fontes municipais para o primeiro incremento

| Município | Percurso público | Evidência e limite |
|---|---|---|
| Gondomar | [Geoportal de ordenamento](https://pdm.cm-gondomar.pt/geoportal/webforms/menu_territorio.aspx?separador=&xml=menu_webpdm.xml), [emissão de plantas](https://pdm.cm-gondomar.pt/geoportal/webforms/webepl.aspx), [PDM municipal](https://www.cm-gondomar.pt/atividade-municipal/planeamento-e-ordenamento/plano-diretor-municipal/) | Menu GET 200; ordenamento, condicionantes, REN, ruído e suspensões. O portal ressalva consulta da versão original e eficácia de exclusões REN dependente de publicação. Não foi testada emissão de documentos nem confirmada API municipal OGC |
| Maia | [Portal Geográfico](https://websig.cm-maia.pt/), [ficha municipal](https://diretorio.cm-maia.pt/diretorio-de-servicos/directorio_de_servicos/espaco-publico/portal-geografico) | Raiz GET 200 com redirecionamento HTML para `/geoportal2026`, também GET 200. Ficha atualizada em 12/08/2026 descreve mapas/plantas/planos; não confundir esse frontend com contrato API. CRUS WMS verificado é da DGT |
| Ponte de Lima | [SIG](https://websig.cm-pontedelima.pt/), [visualizador](https://websig.cm-pontedelima.pt/visualizador) | Fonte oficial indexada descreve consulta, pesquisa e emissão de plantas; GET direto falhou validação da cadeia TLS neste ambiente. Não foi desativada a validação nem testada impressão. Não declarar indisponibilidade universal |

O [aviso oficial da Junta de Fontão, de 06/01/2026](https://www.jf-fontao.pt/autarquia/noticias/23-discussao_publica_2a_revisao_do_pdm_plano_diretor_municipal) documenta discussão da 2.ª revisão de Ponte de Lima entre 6 de janeiro e 2 de março de 2026. É evidência de um procedimento histórico, não de entrada em vigor da revisão nem de participação ainda aberta.

BUPi local: existem [página de Gondomar](https://www.cm-gondomar.pt/atividade-municipal/planeamento-e-ordenamento/bupi-balcao-unico-do-predio/), [ficha da Maia](https://diretorio.cm-maia.pt/diretorio-de-servicos/directorio_de_servicos/urbanismo/bupi-balcao-unico-do-predio) e [informação municipal de Ponte de Lima sobre o balcão](https://www.cm-pontedelima.pt/cmpontedelima/uploads/document/file/6583/agenda_pl_02_2024.pdf). A última é de fevereiro de 2024: serve para encontrar o canal, não para prometer horário/local atuais. A ficha Maia ainda contém referências a 2024/2025; rever taxas e atendimento na fonte específica antes de os reproduzir.

## BUPi: consulta, identificação, registo e representação

Encaminhar para o [Mapa Público BUPi](https://mapapublico.bupi.gov.pt/pesquisaprocesso), a [consulta de cobertura municipal](https://bupi.gov.pt/pt/municipios-aderentes) e a [documentação oficial](https://bupi.gov.pt/pt/documentacao), sem pedir artigo matricial no eCidadão. Não foram abertas fichas de parcelas. A cobertura BUPi depende do município e da situação cadastral; presença de dados no mapa não comprova titularidade.

A documentação BUPi exige autenticação por CMD ou Cartão de Cidadão para entrar na plataforma; representação requer procuração ou declaração, e os profissionais têm documentação própria. A identificação RGG e o registo predial são etapas distintas. As [FAQ oficiais](https://bupi.gov.pt/pt/perguntas-frequentes) distinguem o mapa da consulta pública da apresentação de reclamação: esta encaminha para autenticação e tem prazo próprio. O eCidadão pode explicar o percurso e preparar uma lista de documentos, mas não assumir representação, validar estremas ou emitir comprovativo oficial.

**Não publicar «BUPi sempre gratuito».** A página nacional de municípios consultada nesta data anuncia identificação totalmente online sem custo, mas valores para RGG assistida em balcão, e remete custos de registo para a conservatória; páginas municipais e outras páginas públicas contêm mensagens genéricas de gratuitidade. Tratar custos como informação datada a confirmar no canal oficial, não como constante de produto.

## Condições de integração

Os [termos OGC DGT em JSON](https://dgterritorio.github.io/ToS/en/terms-of-use.json), obtidos com 200, pedem paginação, filtros, limitação de concorrência, reutilização de resultados e tratamento de indisponibilidade; identificam CC BY 4.0 e remetem à licença da coleção. Não foi encontrado nesses termos um SLA ou quota numérica garantida. As [condições de dados abertos DGT](https://www.dgterritorio.gov.pt/dados-abertos) exigem atribuição à entidade; conservar também ligação à licença e indicação de transformações. Licença de dados não autoriza operações autenticadas nem substitui a avaliação de adequação ao uso.

Decisões de implementação propostas, não limites impostos pelos fornecedores: allowlist de origens/coleções; timeout 10–20 s; no máximo 1–2 pedidos simultâneos por origem; cache de metadados 24 h; leitura de 10–30 resultados por página; retries limitados com backoff para 429/503; nenhuma repetição automática de 403; XML sem resolução de entidades externas. Verificar CORS antes de integração direta no browser; proxy de leitura controlado se necessário. Estes aspetos e o suporte a filtros espaciais por coleção ainda precisam de ensaios.

Não guardar pesquisas de localização nem ligar geometrias a pessoas. Primeiro incremento recebe apenas município/tema; um futuro mapa deve usar extensão visível limitada, nunca descarregar um país inteiro ao abrir a página. Não reter cookies nem respostas de plataformas autenticadas.

## Três incrementos independentes

1. **Guia territorial municipal e BUPi.** Catálogo estático dos três municípios, fontes oficiais, documentos a preparar e explicação PDM/condicionantes/RGG/registo; PT/EN e data de verificação. Contrato proposto `territory_guidance({municipality, topic, language})`, com temas `pdm|constraints|bupi|cadastre`, `status=guidance_only`, `submitted=false`. Aceitação: destinos oficiais, distinção entre revisão e vigência, sem dados pessoais, sem afirmações de gratuitidade/edificabilidade não verificadas. Pode ser entregue sem rede no runtime.
2. **Pesquisa de metadados oficiais.** Adaptador OGC Records para `snig`, com pesquisa textual limitada, paginação, título, cobertura, data, licença/restrições e acesso ao registo original. Contrato `territory_sources({municipality, topic, limit})`, `status=metadata_only`; devolver falha explícita quando houver 503. Aceitação: teste real pequeno `q=Maia`, fixtures de erro, sanitização de HTML/URLs e datas distintas; não prometer que todos os recursos encontrados são abertos. Independente do mapa e do BUPi autenticado.
3. **Piloto de camadas territoriais públicas.** Começar pelo WMS CRUS Maia já verificado e descoberta de REN DGT; legenda, escala, fonte e aviso de finalidade. Antes de ativar interseções, testar bbox/CRS/limites em área pública genérica, confirmar filtros e cobertura local e reconciliar publicação legal. Contrato `territory_layers({municipality, theme})`, `status=map_information_only`, sem resposta binária sobre construir. BUPi fica como ligação ao visualizador até GetCapabilities funcionar por via normal; não depende de resolver os 403 para entregar o piloto DGT.

Restante trabalho: validar apresentação visual do GetMap e legendas ponta a ponta, filtros/bbox DGT por coleção, CORS e cobertura local de condicionantes; reconciliar versões legais de PDM; revalidar atendimento/custos BUPi; confirmar acesso normal aos serviços RGG. Nada nesta proposta permite automatizar identificação, registo, representação ou submissão oficial.
