# Submissão pública eCidadão 0.3.1

Estado em 13 de novembro de 2026, comunicado pelo editor: **In review** no OpenAI Platform. O pacote e o endpoint estão ativos; a aprovação e a publicação no diretório ainda estão pendentes.

## Materiais

- ZIP: `ecidadao-plugin-0.3.1.zip` (manifesto, MCP e duas skills).
- MCP de candidatura: `https://ecidadao.pt/mcp/public`, sem autenticação.
- Site: `https://ecidadao.pt`; apoio: `/apoio`; privacidade: `/privacidade`; termos: `/termos`.
- Vídeo técnico de 61 segundos com chamadas reais ao MCP: `https://ecidadao.pt/review/ecidadao-0.3.1-7aaa4cd838b2e9c17e6fc6fb5f6f9705.mp4`. Mostra os cinco casos positivos e três limites; não demonstra a seleção automática das ferramentas dentro do ChatGPT.
- Editor: Código Inadiável; a identidade selecionada no painel deve pertencer à empresa e coincidir com os dados públicos.

O endpoint público oferece seis ferramentas: `siga_visit_guidance`, `financas_service_guidance`, `prepare_financas_ebalcao`, `prepare_street_report`, `prepare_complaint` e `official_submission_guidance`. Não consulta filas, ocorrências recentes ou contas; não submete pedidos. A consulta SIGA do site usa rotas internas sem autorização de integração confirmada; só deverá entrar no plugin após autorização do operador e nova revisão.

## Justificações para as anotações MCP

As seis ferramentas têm `readOnlyHint: true`, `destructiveHint: false` e `openWorldHint: false`. Para cada uma, indicar no painel:

| Ferramenta | Justificação |
| --- | --- |
| `siga_visit_guidance` | Devolve texto e URLs fixos. Não consulta o SIGA, não emite senha e não altera estado. |
| `financas_service_guidance` | Escolhe entre URLs oficiais fixos conforme a categoria indicada. Não acede a contas nem altera estado. |
| `prepare_financas_ebalcao` | Formata localmente o assunto e a mensagem fornecidos pela pessoa; não guarda nem envia o texto à AT. |
| `prepare_street_report` | Valida e formata localmente os campos; não os envia à ARTE ou à autarquia. |
| `prepare_complaint` | Valida e formata localmente os campos; não os envia ao Livro de Reclamações. |
| `official_submission_guidance` | Devolve passos e URL oficial fixos; não acede a processos nem submete reclamações. |

Nenhuma ferramenta acede à internet durante a chamada, altera estado persistente ou causa efeitos irreversíveis. As URLs devolvidas são para navegação posterior da pessoa.

## Ações no painel

1. Em `https://platform.openai.com/plugins`, selecionar a organização/projeto com identidade empresarial verificada e permissão de publicação. Projetos com residência de dados exclusivamente na UE não são elegíveis para submissão MCP nesta fase.
2. Escolher **With MCP**, carregar o ZIP 0.3.1 e corrigir eventuais findings de metadados/skills.
3. Em MCPs, ligar `https://ecidadao.pt/mcp/public`. Copiar o token de verificação gerado pelo painel para `OPENAI_APPS_CHALLENGE` no `.env` do servidor e recriar o contentor. Confirmar que `https://ecidadao.pt/.well-known/openai-apps-challenge` devolve apenas o token; depois clicar **Verify Domain**.
4. Executar o scan e confirmar as seis ferramentas e as suas anotações. Inserir as justificações acima.
5. Testar no ChatGPT os cinco casos positivos e três negativos importados pelo manifesto, em desktop e mobile. Guardar os resultados.
6. Colar o URL do vídeo técnico nos Review details. Para mostrar também a seleção automática de ferramentas e a ativação das skills, gravar uma demonstração adicional dentro do ChatGPT antes da submissão final, se o painel permitir substituir o vídeo.
7. Verificar os dados de revisão, release notes e declarações; escolher **Submit for review**. Após aprovação, selecionar **Publish plugin**.

Fontes: [submissão](https://developers.openai.com/plugins/deploy/submission), [validação](https://developers.openai.com/plugins/deploy/submission-errors), [diretrizes](https://developers.openai.com/plugins/plugin-guidelines).
