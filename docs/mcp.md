# MCP e alojamento próprio

## Ligar ao serviço público

Endpoint: `https://ecidadao.pt/mcp/public`. Transporte Streamable HTTP, JSON-RPC 2.0, sem autenticação ou sessões persistentes.

```sh
curl --fail-with-body https://ecidadao.pt/mcp/public \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  --data '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

O catálogo público inclui `siga_visit_guidance`, `financas_service_guidance`, `prepare_financas_ebalcao`, `prepare_street_report`, `prepare_complaint` e `official_submission_guidance`. Use `tools/list` para obter os parâmetros de cada ferramenta. Os rascunhos não são guardados nem submetidos a portais oficiais.

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
