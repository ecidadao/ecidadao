# Descoberta pública de serviços e locais no gov.pt

Verificado em **26 de novembro de 2026**, aproximadamente 20:40–20:50 UTC. Complementa `integration-opportunities.md` e o inventário iAP, lidos antes desta pesquisa. Foram consultados HTML, JavaScript público e documentação oficial; não foram usados credenciais, cookies previamente obtidos, dados pessoais, contas ou operações administrativas. Os únicos POST foram pesquisas de leitura do próprio portal. Não foram enviados contactos nem pedidos de adesão.

## Resultado para o eCidadão

**Há uma fonte anónima funcional além dos metadados iAP:** a pesquisa do atual `www.gov.pt` devolve JSON com serviços, locais, coordenadas, horários e ligações oficiais. As páginas públicas de detalhe incluem JSON estruturado com requisitos, procedimentos e associações entre local e serviço. É suficiente para um protótipo de descoberta «o quê / onde / como», mas **não é uma API de integração publicamente contratualizada** nem uma operação de marcação.

Recomendação: usar este resultado para definir o adaptador e validar os campos necessários; manter o CUSP como percurso para um contrato suportado. Antes de republicação comercial, resolver os direitos de reutilização. Atualização posterior: o [pedido técnico CUSP](cusp-access-request.md) foi enviado à ARTE e aguarda resposta. Não foi alterado código de produto.

## 1. Pesquisa realmente utilizada pelo portal

Fontes primárias de descoberta:

- [Página de pesquisa](https://www.gov.pt/pesquisa/Cart%C3%A3o%20de%20Cidad%C3%A3o).
- [Pesquisa de locais](https://www.gov.pt/locais-de-atendimento).
- [Bundle comum observado](https://www.gov.pt/_next/static/chunks/pages/_app-c52dfecb77571a65.js): módulo `64003`, função `getSearchResult`, envia o corpo abaixo para `/api/post-search-result`; módulo `79418` define os templates e valores iniciais.
- [Bundle da pesquisa](https://www.gov.pt/_next/static/chunks/78680-0923992415b15981.js): módulo `79686` usa `value`, `category`, paginação e o resultado `hits`.
- [Bundle da página de locais](https://www.gov.pt/_next/static/chunks/pages/locais-de-atendimento-e74e61282e555320.js): seleciona `local_search_template`.
- [Bundle da lista/mapa](https://www.gov.pt/_next/static/chunks/82939-711801f766b6f24e.js): converte `_source.location.lat/lon` em marcadores; inclui `filterByGeo`, `latitude` e `longitude` na pesquisa do mapa.

Os nomes com hash são evidência desta versão; não devem ser fixados no produto. Build observado no HTML: `Z2Kq3nmK0iqYPiK-SdWob`.

### Pedido reproduzível: serviços

```sh
curl --fail-with-body --max-time 30 \
  'https://www.gov.pt/api/post-search-result' \
  -H 'Content-Type: application/json' \
  --data-raw '{"method":"POST","body":{"id":"geral_search_template","params":{"size":"10","start":"0","hasThemes":false,"hasSubThemes":false,"value":"Cartão de Cidadão","category":""}}}'
```

Resposta observada: **HTTP 200**, `application/json; charset=utf-8`, sem Authorization nem Cookie no pedido. O servidor pode emitir um cookie WAF na resposta; não foi necessário guardá-lo ou reenviá-lo.

Estrutura (seleção de campos observados):

```text
took, timed_out, _shards.{total,successful,skipped,failed}
hits.total.{value,relation}
hits.hits[].{_index,_id,_score,_source,highlight}
  _source.title, description, url, category, categories[]
  _source.entity[], channelType[], website?, themeAndSubtheme[], isLGP
aggregations
```

A pesquisa devolveu `hits.total = {value: 1008, relation: "eq"}` e dez resultados. Entre eles, `CES:SRV:000000458`, **Renovar o Cartão de Cidadão**, com URL `/servicos/renovar-o-cartao-de-cidadao`, entidade `SIOE:ORG:152600000` e canal web oficial. Os 1.008 resultados são correspondências de texto de várias categorias, **não** 1.008 serviços de CC. Uma pesquisa separada, alterando apenas `value` para `""`, `category` para `"Serviços"` e `size` para `"1"`, devolveu **2.497** (`relation: eq`); só foi descarregado um registo, não o catálogo completo.

`website` e `channelType` são metadados de encaminhamento, não prova de que o eCidadão possa executar esses canais. Não seguir automaticamente URLs de autenticação nem tratar todos os canais da lista como equivalentes.

### Pedido reproduzível: locais de Rio Tinto

Mesmo endpoint e cabeçalho, com este corpo exato:

```json
{"method":"POST","body":{"id":"local_search_template","params":{"size":"10","start":"0","hasThemes":false,"hasSubThemes":false,"sort":"title.sort","order":"asc","filterByGeo":false,"value":"Rio Tinto","category":"Locais de atendimento"}}}
```

HTTP 200; `hits.total = {value: 2, relation: "eq"}`. Cada hit tem `_index: search-localcare-pt`, `_id` CES e `_source` com `title`, `addressOrganization`, `mainAddress.{address,postalCode}`, `openingHours`, `phoneNumber`, `location.{lat,lon}`, `url`, `category` e `groupCode[]`.

| Identificador observado | Local | Coordenadas | Horário publicado |
|---|---|---|---|
| `CES:POC:000005107` | Espaço Cidadão de Rio Tinto | 41.17705, -8.557701 | Dias úteis, 9h–15h |
| `CES:POC:000007337` | Segurança Social — Serviço Local de Rio Tinto | 41.174294, -8.557187 | Dias úteis, 9h–16h; tesouraria encerra 13h–14h |

A alteração `size: "1", start: "1"` devolveu apenas o segundo local: paginação por offset confirmada neste exemplo. A alteração `value: "", size: "1"` devolveu total **3.818** (`relation: eq`) e um registo da 1.ª Conservatória do Registo Civil do Porto. Isto mede o índice do portal, não certifica cobertura nacional, duplicados, todas as conservatórias ou todos os serviços em cada balcão. Só a língua portuguesa foi testada.

### Limite importante da pesquisa geográfica

Foi feito um único pedido adicional com o corpo dos locais, alterando `value: ""`, `sort: ""`, `filterByGeo: true`, `latitude: 41.17705`, `longitude: -8.557701` e mantendo `size: "10"`. O servidor respondeu 200 e **1.487** resultados totais; os dez devolvidos incluíam Tarouca, Aveiro, Nelas, Penafiel, Ponte da Barca, Murça, Viseu, Braga e Valongo.

**Não ficou demonstrada ordenação por distância nem o raio aplicado.** Não anunciar «o mais próximo» com base nessa chamada. Há coordenadas utilizáveis para calcular distância a um conjunto explicitamente limitado de candidatos, mas a obtenção completa desse conjunto e os filtros por serviço/concelho precisam de validação adicional ou contrato CUSP. Não foi executada uma extração nacional.

## 2. Detalhes estruturados em GET público

As respostas HTML contêm `<script id="__NEXT_DATA__" type="application/json">`. Extrair o JSON e ler `props.pageProps`; não é necessário executar JavaScript nem autenticar. Não foi testada uma rota `_next/data` dependente do build, nem um backend interno do CMS.

### Local: serviços, horário e restrições

```sh
curl --fail-with-body --max-time 30 \
  'https://www.gov.pt/locais-de-atendimento/espaco-cidadao-de-rio-tinto'
```

Em `props.pageProps.localData` observaram-se:

- `hero.{title,updatedAt}`: atualização `2026-11-06T20:01:40Z`.
- `generalInformation.mainAddress`: morada, código postal, país, distrito, concelho, latitude e longitude; `contacts[]` e `schedule[]`.
- `serviceLocationCodeCes: "CES:POC:000005107"`.
- `operatingRestrictions[].description`, `slug`, `keywords`, `metaDescription`.
- `servicesAndDivisions[]`: **158 entradas**, com `title`, `code` e `type`. Inclui `CES:SRV:000000458` (renovação), `CES:SRV:000000462` (morada), `CES:SRV:000000544` (confirmação de morada) e `CES:SRV:000000459` (cancelamento).

Há uma restrição que ainda menciona o feriado municipal de **2025**, apesar de a página ter atualização em 2026. O timestamp da página não garante que todos os campos tenham sido revistos. Horários e exceções são texto livre, não um calendário de disponibilidade. Fonte: [local de Rio Tinto](https://www.gov.pt/locais-de-atendimento/espaco-cidadao-de-rio-tinto).

### Serviço: requisitos, passos e canais

```sh
curl --fail-with-body --max-time 30 \
  'https://www.gov.pt/servicos/renovar-o-cartao-de-cidadao'
```

HTTP 200. `props.pageProps.seoInfoResp` contém `code`, `dateCreated`, `dateModified`, `url`, `language` e `pagetitle`; para este serviço, ambas as datas eram `2026-10-19T15:30:22Z`. `serverSideContent` contém, entre outros:

```text
config.entityId / entityIds
entitySection / entitySections
how.serviceChannels[].{title,type,verticalTabs}
  verticalTabs[].{id,title,descriptions,footerInfo,contacts}
  descriptions[].{code,name,description}
  footerInfo.button.{label,url,...}
duedate.descriptions[]
```

Os textos dos separadores contêm requisitos, passos, custos e prazos em Markdown; preservar a relação com cada canal e as ligações oficiais. O primeiro `website` de um resultado de pesquisa não substitui estes detalhes.

**Caso CC perto de Rio Tinto:** a associação da página do local confirma que o portal lista renovação nesse Espaço Cidadão. A [página de renovação](https://www.gov.pt/servicos/renovar-o-cartao-de-cidadao) condiciona o atendimento em Espaço Cidadão à elegibilidade para renovação assistida, incluindo idade, nacionalidade, validade, biometria registada e autenticação. Não equivale a um balcão IRN capaz de atualizar biometria ou aceitar todos os pedidos. O produto deve primeiro distinguir renovação assistida elegível, renovação presencial no IRN, primeira emissão, alteração de morada e levantamento. A página remete para SIGA em situações de atendimento IRN; isso **não verifica uma API de marcação de CC**.

## 3. Contrato, atualizações e direitos

| Aspeto | Observado / limitação |
|---|---|
| Acesso | Pesquisas e duas páginas de detalhe acessíveis anonimamente; não demonstrado CORS para aplicação de terceiro. |
| Contrato | Descoberto no JavaScript público, sem OpenAPI, SLA, quota ou política de depreciação identificados para `/api/post-search-result`. |
| Versão | Build e bundles com hash mudam em deploy; estrutura da página e templates não são contrato estável. |
| Integridade | Verificar HTTP, JSON, `timed_out`, `_shards.failed` e `hits.total.relation`; falhas não devem produzir «não existem locais». |
| Cobertura | Contagens do índice, não auditoria; nenhuma verificação de cobertura territorial completa, traduções ou serviços por entidade. |
| Atualização | Datas nos detalhes; não verificado feed incremental, `updated_since`, tombstones ou cadência de sincronização. Search response tinha ETag, mas validação condicional não foi testada. |
| Reutilização | Os termos gerais do gov.pt permitem reutilização com atribuição para uso pessoal/público sem fins lucrativos ou ofensivos; não são uma licença aberta irrestrita para integração comercial. Confirmar direitos, cache, indexação, redistribuição e respostas MCP antes dessa utilização. |

Os [termos do gov.pt](https://www.gov.pt/termos-e-condicoes), atualizados a 25/08/2025, também permitem links, proíbem cobrar pelo clique ou alegar associação ao portal, e avisam que os conteúdos podem mudar ou desaparecer sem aviso. A licença do dados.gov.pt não deve ser transferida para estes dados apenas por ambas as plataformas pertencerem ao Estado.

O [guia oficial da API CUSP](https://guias.mosaico.gov.pt/plataformas-comuns-da-administracao-publica/catalogo-unico-de-servicos-publicos-cusp/quais-os-pre-requisitos-tecnicos-de-adesao/api-publica-do-cusp) confirma API Key fornecida na adesão e contratos/DTO ainda sujeitos a alterações. Os identificadores documentados `SRV-…` / `POC-…` diferem do formato `CES:SRV:…` / `CES:POC:…` observado no portal: pedir correspondência explícita, não converter por hipótese.

## 4. Outros resultados e limites da investigação

- `GET https://mapa.eportugal.gov.pt/` falhou por resolução DNS neste ambiente. Não demonstra indisponibilidade global nem se tentou contornar o problema. O mapa atual verificável é o componente de `/locais-de-atendimento` descrito acima.
- O caminho antigo `/locais-de-atendimento-de-servicos-publicos`, ainda presente em ligações do portal, terminou em HTTP 503 depois de redirecionamentos; `/locais-de-atendimento` respondeu 200. Não usar o caminho antigo como único encaminhamento.
- `GET https://www.gov.pt/robots.txt` respondeu 404 nesta observação; isso não constitui autorização de extração ou licença.
- Não foram investigados dados privados, URLs de autenticação, operações de marcação, o backend de escrita, nem o novo Livro Amarelo.

## Reprodução e próximo passo

```sh
python3 scripts/probe_service_discovery.py > /tmp/service-discovery-evidence.json
```

O probe faz exatamente quatro pedidos de leitura (duas pesquisas POST e dois GET), com timeout e limite de resposta; imprime pedidos, respostas, timestamp e build. Não pagina, não descarrega todos os locais e não persiste cookies. Sai com erro se a resposta de pesquisa estiver incompleta ou o contrato básico mudar. As contagens exploratórias nacional/geográfica acima não fazem parte dos quatro pedidos padrão.

Para implementação futura: modelar serviço, canal, local e associação por identificadores; conservar fonte e data de verificação; apresentar requisitos por canal antes de sugerir deslocação; encaminhar para a página oficial quando faltarem dados; não prometer distância mínima, horário atual ou marcação concluída. A decisão de integração comercial e o acesso suportado continuam dependentes de resposta ao pedido CUSP, já enviado e a aguardar resposta.
