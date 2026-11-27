# MCP e alojamento próprio

## Ligar ao serviço público

Endpoint: `https://ecidadao.pt/mcp/public`. Transporte Streamable HTTP, JSON-RPC 2.0, sem autenticação ou sessões persistentes.

```sh
curl --fail-with-body https://ecidadao.pt/mcp/public \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  --data '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

O catálogo público inclui `siga_visit_guidance`, `financas_service_guidance`, `prepare_financas_ebalcao`, `prepare_street_report`, `prepare_complaint`, `official_submission_guidance`, `sns24_service_guidance`, `municipal_service_search`, `municipal_appointment_availability` e `public_support_guidance`. Use `tools/list` para obter os parâmetros de cada ferramenta. Os rascunhos não são guardados nem submetidos a portais oficiais.

Os plugins e comandos de instalação para Codex e Claude Code estão em [ecidadao/plugins](https://github.com/ecidadao/plugins).

## Executar localmente com Docker

```sh
docker build -t ecidadao .
docker run --rm -p 127.0.0.1:4000:4000 \
  -e SECRET_KEY_BASE="$(openssl rand -hex 64)" \
  -e PORT=4000 ecidadao
```

Verifique `http://localhost:4000/health`. O MCP público local fica em `http://localhost:4000/mcp/public`. Clientes executados noutra máquina precisam de um endereço acessível por HTTPS.

Para produção, configure `SECRET_KEY_BASE` através de um gestor de segredos ou ficheiro `.env` excluído do Git. Configure `MCP_ALLOWED_ORIGINS` com as origens web autorizadas, separadas por vírgulas. Use um proxy HTTPS à frente da aplicação; `compose.yaml` e `Caddyfile` são exemplos que devem ser adaptados ao domínio escolhido. Consulte `config/runtime.exs` para as variáveis suportadas.

A aplicação não precisa de base de dados. Não registe corpos de pedidos contendo rascunhos. O endpoint `/mcp` expõe funcionalidades adicionais, incluindo consultas a fontes externas; avalie as condições desses serviços antes de as disponibilizar. O pacote público usa apenas `/mcp/public`.


## Livro Amarelo no endpoint experimental

`prepare_public_service_feedback` está disponível exclusivamente em `/mcp`. Não integra as dez ferramentas de `/mcp/public` nem altera a distribuição independente dos plugins. `prepare_complaint` continua a preparar reclamações de consumo para o Livro de Reclamações Eletrónico.

## Municípios e apoios — 0.3.4

As três ferramentas aceitam apenas os campos documentados e recusam campos pessoais adicionais, sem os refletir. Estão disponíveis em ambos os endpoints MCP.

| Ferramenta | Parâmetros | Resultado e limite |
|---|---|---|
| `municipal_service_search` | `municipality`: all/gondomar/maia/ponte_de_lima; `query` até 160 caracteres; `limit` 1–30; `language` pt/en | Catálogo local de 320 entradas: 136 Gondomar, 126 Maia, 58 Ponte de Lima. Fonte de 27/11/2026; títulos oficiais em português. Sem consulta de disponibilidade ou processos |
| `municipal_appointment_availability` | `municipality`: ponte_de_lima; `service_id` opcional, inteiro devolvido pela lista; `date` ISO opcional, requer serviço; `language` pt/en | Sem serviço lista áreas; com serviço lista datas; com data lista horários. Fonte municipal externa, horários Europe/Lisbon, `checked_at`, `reserved:false`. Nenhuma reserva |
| `public_support_guidance` | `service`: porta65_young/porta65_plus/gondomar_housing/environmental_fund/vale_efficiency/elar/green_mobility; `language` pt/en | Orientação datada com fases e prazos, `submitted:false`, sem consulta de orçamento, conta ou elegibilidade pessoal |

Pesquisa e orientação não fazem chamadas externas. A disponibilidade usa apenas GET em destinos fixos de Ponte de Lima, com validação dos serviços devolvidos, timeout, limite de resposta e cache de 30 segundos que conserva a hora da observação. Erros da fonte nunca são apresentados como ausência de vagas. O cache limita consultas novas por instância; não é um limite distribuído. A interface usada pelo portal pode mudar e não tem contrato público de suporte externo confirmado.

Páginas: `/municipios`, `/vagas`, `/apoios`. APIs web: `POST /api/municipal/services` e `POST /api/municipal/appointments`; JSON. A segunda devolve 422 para argumentos inválidos, 429 para limite temporário e 503 quando a fonte não está disponível. Revalidar e concluir sempre no portal oficial.

```json
{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"municipal_service_search","arguments":{"municipality":"gondomar","query":"tarifário água"}}}
```

```json
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"municipal_appointment_availability","arguments":{}}}
```

```json
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"public_support_guidance","arguments":{"service":"porta65_plus","language":"en"}}}
```

A ferramenta recebe `type` (`complaint`, `compliment` ou `suggestion`), `organisation`, `subject` e `description`. Aceita ainda `location`, `incident_date` (AAAA-MM-DD, se conhecida) e `requested_resolution`. Organização, local e assunto têm limite de 200 caracteres; descrição, 5000; resultado pretendido, 1500. Campos opcionais podem ser omitidos. Campos desconhecidos são descartados e não aparecem no rascunho; não envie nomes pessoais, NIF, contactos, credenciais ou códigos, incluindo no texto livre.

A resposta contém `status: rascunho_nao_submetido`, `type`, `fields`, `draft`, `official_portal`, `authentication_required` e `next_step`. Erros de validação surgem em `structuredContent.errors` com `isError: true`. A API web equivalente, `POST /api/public-feedback/prepare`, devolve JSON com HTTP 200 ou 422 e `Cache-Control: no-store`.

A preparação é local, sem persistência ou chamadas de rede: não autentica, não submete e não emite comprovativos. A identificação e a autenticação são feitas apenas no portal oficial. Os percursos oficiais, verificados em 26 de novembro de 2026, são:

- Reclamação: https://www.gov.pt/servicos/fazer-reclamacao-de-um-servico-publico
- Elogio: https://www.gov.pt/servicos/fazer-elogio-a-um-servico-publico
- Sugestão: https://www.gov.pt/servicos/fazer-sugestao-a-um-servico-publico

Exemplo de pedido JSON-RPC para `POST /mcp`:

```json
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"prepare_public_service_feedback","arguments":{"type":"compliment","organisation":"Câmara Municipal","subject":"Atendimento claro","description":"Recebi uma explicação clara sobre os passos do pedido."}}}
```

## SNS 24

`sns24_service_guidance` está no MCP público e experimental desde 0.3.3. `service`: appointments/exams/medication/referrals; `language`: pt/en (pt por omissão); `channel`: portal/app/both (both por omissão). Devolve orientação estática, fonte e data de revisão; não consulta nem altera dados no SNS. Não envie dados pessoais.
