# Ligar o MCP eCidadão no telemóvel

> Registo histórico dos testes de 13 de novembro de 2026 com o endpoint experimental `/mcp`. Para novas instalações, use `/mcp/public` e siga [o guia actual](mcp.md). As seis ferramentas públicas não incluem comparação de filas.

Endpoint público: **`https://ecidadao.pt/mcp`**. O servidor usa Streamable HTTP e não pede conta eCidadão. Expõe dez ferramentas de consulta, orientação e preparação de rascunhos. Senhas, marcações e pedidos oficiais são concluídos nos portais das entidades.

## Verificação rápida do MCP

```sh
curl -fsS https://ecidadao.pt/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  --data '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

A resposta deve conter `result.tools` com `compare_siga_queues`, `siga_visit_guidance`, `financas_service_guidance` e `prepare_financas_ebalcao`, além das ferramentas de reclamações e A Minha Rua.

Em 13 de novembro de 2026, o endpoint também passou a inicialização, listagem e chamada de ferramenta com o cliente oficial TypeScript MCP `@modelcontextprotocol/client` 2.4.0. Isto confirma o protocolo, mas não substitui um teste dentro das apps.

## Claude no iPhone ou Android

1. Em [claude.ai](https://claude.ai), abra **Customize → Connectors → + Add → Add custom connector**. Em contas Team/Enterprise, um administrador adiciona o conector em **Organization settings → Connectors**.
2. Nome: `eCidadão`. URL: `https://ecidadao.pt/mcp`. Escolha **No sign in** para o próprio eCidadão.
3. Na app Claude, use a mesma conta. Numa conversa, toque em **+ → Connectors** e ative `eCidadão`.
4. Experimente: “Quero comparar filas da Autoridade Tributária perto de mim, num raio de 40 km.” Claude deve pedir ou confirmar um ponto de partida e o tipo de senha antes da consulta. Para Finanças: “Prepara uma questão sobre IMI para o e-balcão.”

O conector remoto é executado a partir da infraestrutura Anthropic e pode ser usado nas apps móveis após configurado. A interface e as permissões concretas dependem da conta e da versão da app. Fonte: [ajuda oficial Claude para conectores MCP](https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp).

## ChatGPT móvel e Codex

1. Em [ChatGPT Plugins](https://chatgpt.com/plugins) na web, selecione **+ → Add custom MCP server** e indique `https://ecidadao.pt/mcp`, nome `eCidadão` e autenticação sem login.
2. Crie e instale o plugin de teste. Abra uma nova conversa na app ChatGPT, em **Chat** ou **Work**, escolha `@eCidadão` e peça uma consulta ou rascunho.
3. Para Codex no computador, a ligação direta também pode ser adicionada com `codex mcp add ecidadao --url https://ecidadao.pt/mcp`. Confirme com `codex mcp list` e inicie uma nova sessão.

Os [plugins funcionam no ChatGPT móvel](https://learn.chatgpt.com/docs/plugins). A documentação lista Codex com plugins na app ChatGPT **desktop** e no CLI; o [Codex no telemóvel](https://learn.chatgpt.com/docs/mobile) serve para iniciar, acompanhar e rever tarefas remotas. Para testar o eCidadão diretamente no telefone, use ChatGPT Chat/Work ou Claude.

## O que se deve ver

| Pedido | Ferramenta esperada | Resultado esperado |
| --- | --- | --- |
| Comparar filas por local e raio | `compare_siga_queues` | Balcões, distância em linha reta, estado, espera publicada e hora da consulta; sem senha emitida. |
| Marcar atendimento | `siga_visit_guidance` | Link e passos para concluir a marcação no SIGA. |
| Dúvida sobre IMI para a AT | `prepare_financas_ebalcao` | Assunto e mensagem para rever e copiar; pedido ainda não submetido. |
| Encontrar serviço de IRS | `financas_service_guidance` | Entrada oficial e instrução para escolher o serviço no Portal das Finanças. |

### Capturas reais do site móvel

As imagens abaixo foram capturadas num navegador Chromium com viewport de 390 px. Mostram o **site eCidadão**, não o Claude nem o Codex. A lista SIGA foi consultada com coordenadas de exemplo; os tempos mudam.

- [SIGA antes da pesquisa](screenshots/siga-mobile.png)
- [SIGA com resultado de exemplo](screenshots/siga-resultado-mobile.png)
- [Finanças antes do rascunho](screenshots/financas-mobile.png)
- [Finanças com rascunho de exemplo](screenshots/financas-rascunho-mobile.png)

Ainda não há capturas de uma sessão real do conector nas apps Claude, ChatGPT ou Codex. Para as obter, é preciso adicionar o MCP à conta respetiva e executar os prompts acima num dispositivo real.
