# Contrato do mapa de cobertura municipal

Revisão de capacidades e coordenadas: **2026-11-27**. Base: integrações existentes da versão 0.3.4, atualizadas nesta worktree a partir de `origin/main` (`8842028`). Este incremento fornece dados de cobertura; não acrescenta ferramenta MCP nem faz consultas públicas externas ao carregar o mapa.

## Entrada e resposta

```elixir
Ecidadao.MunicipalCoverage.snapshot("pt")
Ecidadao.MunicipalCoverage.snapshot("en")
```

Devolve diretamente um mapa serializável por Jason, com chaves atom em Elixir e strings em JSON; sem tuplo `{:ok, ...}`. O idioma predefinido é `pt`; outros valores fazem fallback para `pt`. O integrador pode validar `lang=pt|en` na rota prevista `GET /api/municipal/coverage?lang=pt`. Não recebe localização, identificadores pessoais ou coordenadas do visitante.

### Campos acordados com o frontend

O contrato inclui os campos diretos abaixo; os objetos detalhados `center`, `totals`, `national_services` e a proveniência original são conservados como metadados adicionais:

- Topo: `language`, `generated_at`, `revision`, `verified_on`, `municipality_count`, `total_service_count`, `municipalities`, `national_capabilities`, `notice`.
- Município: `id`, `code`, `name`, `latitude`, `longitude`, `service_count`, `tools`, `coverage` (texto localizado), `limitations` (lista de textos localizados), `links: [{label, url}]`, `sources: [{label, url}]`, `availability_lookup` (booleano).
- Capacidade nacional: `id`, `title`, `description`, `tools` (lista de nomes MCP), `url`. IDs estáveis: `national_support`, `national_health`, `national_tax`, `national_public_service_visits`.

`availability_lookup=true` apenas em Ponte de Lima e significa capacidade de consulta, não vaga atual. `code` é alias de `administrative_code`; `latitude`/`longitude` correspondem a `center`. As contagens diretas correspondem às de `totals`. Links internos incluem apenas o parâmetro de idioma suportado `lang`; não presumem suporte a um filtro municipal no URL. `sources` fornece destinos humanos oficiais (portal de Gondomar, não menu JSON) e a fonte DGT; `source` mantém a proveniência técnica original.

| Campo | Significado |
|---|---|
| `schema_version` | `1`, versão do formato |
| `revision` | Revisão datada de capacidades com hash das coordenadas e dos catálogos municipal/de apoios compilados; igual em PT/EN; atualizar o prefixo ao alterar capacidades |
| `generated_at` | Instante UTC de construção da resposta; não é consulta ao município nem revalidação das fontes |
| `reviewed_on` | Data da revisão das capacidades integradas |
| `verified_on` | Data mais antiga dos catálogos municipais apresentados; cada município conserva também a sua |
| `language` | Idioma efetivo `pt` ou `en` |
| `status` | Sempre `coverage_snapshot` |
| `availability_checked`, `submitted` | Sempre `false` |
| `municipalities` | Lista ordenada Gondomar, Maia, Ponte de Lima |
| `totals` | `municipality_count`, `service_count`, `live_lookup_municipality_count` |
| `national_services` | Orientação nacional, separada da cobertura municipal e das contagens |
| `labels`, `notice` | Texto localizado para título, estados e explicação da cobertura |

Cada município contém:

- `id`, `name`, `administrative_code`: identificador interno, nome e código DTMN em string, respetivamente `1304`, `1306`, `1607`.
- `center: {latitude, longitude}`: ponto aproximado para colocar o marcador. Não é localização de uma pessoa, parcela ou balcão.
- `coordinate_source`, `coordinate_dataset`, `coordinate_method`, `coordinate_crs`, `coordinate_bbox`, `coordinate_reviewed_on`, `coordinate_license`, `coordinate_attribution`: proveniência e cálculo do ponto.
- `service_count`: `total` de `MunicipalDirectory.search` para esse município; não é hardcoded. Conta entradas de catálogo, incluindo ações de seguimento, não serviços transacionais nem vagas.
- `source`, `verified_on`, `reviewed_on`: fonte original do catálogo e datas separadas.
- `status: "catalogue"`, `availability_checked: false`: o estado municipal base não implica leitura live.
- `tools`: nomes das ferramentas existentes aplicáveis, sem duplicados.
- `capabilities`: objetos com `tool`, `status`, `scope`, `label`, `path`; orientação +Habitação inclui ainda `service: "gondomar_housing"`.
- `paths`: `catalogue`, `appointments`, `support`; destinos internos com `?lang=...`, e `null` quando a capacidade não está integrada nesse município.

### Capacidades municipais

| Município | Ferramenta existente | `status` / `scope` | Caminho |
|---|---|---|---|
| Os três | `municipal_service_search` | `catalogue` / `municipal_catalogue` | `/municipios?lang=pt` |
| Apenas Ponte de Lima | `municipal_appointment_availability` | `live_lookup` / `public_in_person_appointments` | `/vagas?lang=pt` |
| Apenas Gondomar | `public_support_guidance`, serviço `gondomar_housing` | `guidance` / `municipal_support` | `/apoios?lang=pt` |

`live_lookup` significa que existe integração de consulta de horários, **não que haja vagas agora**, que todos os serviços municipais aceitem marcação, ou que exista reserva. A consulta real só acontece no percurso próprio. Não há `slots`, reservas, confirmação de candidatura nem contagem de apoios municipais adicionada a `service_count`.

`national_services` inclui `public_support_guidance` com os IDs de `PublicSupport.services()` exceto `gondomar_housing`, e `sns24_service_guidance`, `financas_service_guidance`, `siga_visit_guidance`. Os seus estados são `guidance`, com âmbitos nacionais e caminhos `/apoios`, `/saude`, `/financas`, `/siga`. Não representam integração transacional com todos os municípios; não aumentam cobertura ou contagens municipais. A lista é uma seleção de percursos nacionais, não o inventário integral do MCP.

## Coordenadas verificadas em dados oficiais

Foram obtidas por GET anónimo as geometrias administrativas CAOP2025 da [OGC API da DGT](https://ogcapi.dgterritorio.gov.pt/collections/municipios?f=json), em 2026-11-27. Não foram consultadas geometrias de parcelas. O código DTMN e nome provêm das propriedades da mesma feature:

| Município | Feature oficial (GET 200 JSON) | Centro calculado: latitude, longitude |
|---|---|---|
| Gondomar | [municípios/182](https://ogcapi.dgterritorio.gov.pt/collections/municipios/items/182?f=json) | `41.102349, -8.478341` |
| Maia | [municípios/184](https://ogcapi.dgterritorio.gov.pt/collections/municipios/items/184?f=json) | `41.237500, -8.604624` |
| Ponte de Lima | [municípios/237](https://ogcapi.dgterritorio.gov.pt/collections/municipios/items/237?f=json) | `41.746979, -8.580598` |

Método declarado `caop_geometry_bbox_midpoint`: obter mínimo/máximo de longitude/latitude de todos os vértices da MultiPolygon, e calcular `(min + max) / 2` em cada eixo, arredondado a seis casas. É o centro da extensão administrativa, **não um ponto oficial de sede, centroide geodésico ou garantia de ponto interior**. A bbox original fica no snapshot para auditar o cálculo; a geometria completa não é persistida. O formato fonte usa CRS84, coordenadas longitude/latitude; a aplicação recebe campos nomeados para evitar inversão de eixos.

Fonte: Direção-Geral do Território, CAOP2025 Municípios — Continente; [licença CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), conforme [publicação de dados abertos DGT](https://www.dgterritorio.gov.pt/dados-abertos). Mostrar atribuição e indicar que os marcadores são derivados. IDs numéricos da coleção são referências da versão consultada, não substituem DTMN para atualização futura.

## Integração no frontend

O mapa pode atualizar este snapshot a partir do backend, mas não deve apresentar «dados municipais em tempo real» para catálogo ou contagens. Usar «catálogo» e «consulta de horários disponível» como estados diferentes. A ausência de marcador significa apenas que o eCidadão ainda não integra esse município, nunca ausência de serviços no país.

A geolocalização opcional pertence exclusivamente ao browser: pedir apenas após ação explícita, usar a posição localmente para enquadrar/calcular distância aos três marcadores e permitir continuar sem a conceder. Não acrescentar latitude/longitude pessoais à chamada de cobertura, URL, logs ou armazenamento. O snapshot não tem campos nem parâmetros para isso. Os campos `center` são coordenadas públicas municipais.

`source` conserva a proveniência técnica original, podendo apontar ao menu JSON de Gondomar; para uma ligação humana usar os `paths` locais ou o portal oficial já mapeado na página municipal. O frontend deve mostrar `name`/`label` como texto e usar os destinos fornecidos, não construir novos nomes de ferramentas. A rota e a página são responsabilidade da integração principal.

## Verificação

`mix test test/municipal_coverage_test.exs test/municipal_directory_test.exs` verifica contagens contra o catálogo real, separação nacional, exclusividade de Ponte para consulta live, ausência de afirmações de reserva, serialização, idiomas, caminhos, códigos e cálculo das coordenadas, e origens HTTPS autorizadas. Os testes não fazem rede. Só `priv/municipal_coverage.json` contém dados novos de posição: três marcadores públicos e a sua proveniência.
