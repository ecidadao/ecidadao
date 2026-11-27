# Verificação das integrações

Cada PR executa os testes Elixir, os percursos Playwright e um cliente do SDK oficial MCP 1.26.0 contra uma instância HTTP local. O check valida inicialização, ping, catálogo exato, JSON Schemas, anotações, nove chamadas positivas sem dependências externas, todos os apoios PT/EN e rejeição de argumentos/capacidades não autorizados. A disponibilidade municipal tem testes determinísticos com respostas injetadas; a consulta real corre separadamente.

Depois de cada deploy, `production-contract` confirma a revisão publicada, páginas e o mesmo contrato MCP por HTTPS. Não depende de disponibilidade das autarquias.

`Live integrations` corre diariamente às 08:23 UTC e por `workflow_dispatch`, com jobs independentes para Ponte de Lima (áreas → datas → horários quando existirem), SIGA (consulta pública no Porto) e A Minha Rua (listagem pública). Não cria reservas nem submete formulários. Zero horários/filas é um resultado válido; um erro de fonte falha o job. A ausência de áreas municipais ou a listagem A Minha Rua ilegível também falham. Os checks externos não bloqueiam PRs nem provocam rollback por falha de terceiros.

Os artefactos incluem data, versão/protocolo, contagens e resultados, sem guardar textos de ocorrências ou dados pessoais. GitHub Actions assinala falhas segundo as notificações configuradas pelo responsável; não existe envio de email adicional pelo eCidadão.

Execução local:

```sh
python -m pip install --require-hashes -r scripts/requirements-ci.txt
python scripts/check_mcp_local.py
python scripts/check_mcp.py https://ecidadao.pt/mcp/public --live
python scripts/check_external.py siga
python scripts/check_external.py street
```

Dependências do cliente estão fixadas com hashes. Atualizar com `uv pip compile scripts/requirements-ci.in --python-version 3.12 --output-file scripts/requirements-ci.txt --generate-hashes` e rever o diff.

Estes testes comprovam transporte, contrato e respostas verificadas. Não comprovam aprovação de versões no diretório OpenAI, sincronização de uma instalação pessoal, escolha de ferramentas por um modelo, elegibilidade de apoios ou execução dentro do ChatGPT/Mistral. Essas verificações exigem evidência própria nos clientes e painéis.
