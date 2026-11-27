# eCidadão

![eCidadão](priv/static/brand/ecidadao-logo.svg)

Aplicação independente e gratuita para comparar filas públicas SIGA, preparar questões para o e-balcão das Finanças e organizar rascunhos de reclamações de consumo e de ocorrências no espaço público em Portugal. Não está associada ao Estado, ao SIGA, à Autoridade Tributária, ao Livro de Reclamações Eletrónico nem à ARTE. **Não emite senhas, não cria marcações e não submete pedidos oficiais**: a pessoa conclui cada ação no portal respetivo.

O código está sob Apache-2.0. A página `/siga` consulta tempos públicos de espera por distrito, entidade e tipo de senha, filtra por raio em linha reta e ordena os balcões abertos pelo tempo observado. A consulta usa endpoints internos do site SIGA, sujeitos a alterações; não garante cobertura de distritos vizinhos nem calcula viagem. A página `/financas` ajuda a encontrar o portal oficial e prepara um rascunho para o e-balcão sem autenticação. A página `/a-minha-rua` consulta ocorrências públicas recentes com cache de dois minutos e prepara um reporte. O envio oficial, a identificação, o consentimento e o reCAPTCHA ficam nos portais oficiais.

A página `/livro-amarelo` prepara reclamações, elogios e sugestões sobre serviços públicos através de `POST /api/public-feedback/prepare`. A preparação é local e sem persistência: não contacta portais, não submete pedidos nem emite comprovativos. A identificação e a autenticação são preenchidas apenas no portal oficial.

O [percurso principal pretendido](docs/photo-first-flow.md) começa com uma fotografia no ChatGPT, pede a confirmação do local e mostra uma prévia antes de qualquer envio. As ferramentas `open_report_camera` e `preview_photo_report` fornecem um protótipo local do cartão de captura e da primeira prévia. A interface ainda precisa de testes no ChatGPT móvel real; o envio oficial depende de integração autorizada.

O [desenho da passagem ao portal A Minha Rua](docs/entrega-ao-portal-oficial.md) mostra os ecrãs, os dados a entregar e o requisito de uma integração da ARTE para abrir o formulário oficial já preenchido.

## Desenvolvimento local

A [matriz de CI e integrações](docs/integration-ci.md) descreve os checks MCP por SDK, testes de publicação e verificações diárias das fontes oficiais.

Requer Elixir 1.20, Erlang/OTP 29 e Node.js para os testes de comportamento da interface.

```sh
mix deps.get
mix test
mix run --no-halt
```

Abra <http://localhost:4000>. A entrada é uma landing page com os serviços por ordem: SIGA/IRN, Finanças, A Minha Rua e Reclamações; o formulário de reclamações está em `/reclamacoes`. Usa `POST /api/complaints/prepare`; A Minha Rua usa `POST /api/street-reports/prepare` e `GET /api/street-reports/recent`; SIGA usa `POST /api/siga/queues/compare`; Finanças usa `POST /api/financas/ebalcao/prepare`. O servidor MCP usa `POST /mcp` com JSON-RPC 2.0 e transporte Streamable HTTP. O endpoint é sem sessões e sem autenticação porque as ferramentas atuais são de preparação, orientação e leitura de dados públicos. Não há base de dados de rascunhos.

Em `/servicos`, a pesquisa por necessidade filtra nove percursos selecionados em português e inglês. Funciona no navegador, sem transmitir o texto pesquisado, e mantém todos os percursos acessíveis sem JavaScript. As ligações encaminham para preparação/consulta no eCidadão ou para páginas oficiais; não é uma pesquisa em tempo real no catálogo CUSP.

Os [testes automáticos de navegador](docs/browser-tests.md) verificam pesquisa, formulários, idiomas, modo escuro, downloads e navegação em Chromium. Execute `npm ci`, `npx playwright install chromium` e `npm run test:browser`. O CI executa a suíte antes de permitir o deploy; os testes iniciam um servidor local isolado e não submetem pedidos a serviços oficiais.

### Exemplo MCP

```sh
curl -sS http://localhost:4000/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  --data '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

As ferramentas expostas incluem `siga_visit_guidance`, `compare_siga_queues`, `financas_service_guidance` e `prepare_financas_ebalcao`, além das ferramentas de reclamações, A Minha Rua e fotografia. `preview_photo_report` recebe apenas uma descrição factual da fotografia, não o ficheiro; devolve uma sugestão de canal e pede confirmação do local. Qualquer função que guarde dados, envie email ou apresente pedidos oficiais precisa de novo desenho de autenticação, consentimento e testes antes de ser exposta.

## Código aberto e plugins

Este repositório contém a aplicação e o servidor MCP. Os pacotes instaláveis, skills e catálogos para Codex e Claude Code são mantidos em [ecidadao/plugins](https://github.com/ecidadao/plugins).

O endpoint recomendado para clientes é `https://ecidadao.pt/mcp/public`: dez ferramentas de pesquisa, consulta, orientação e preparação de rascunhos, sem autenticação. Inclui pesquisa municipal, disponibilidade de atendimento em Ponte de Lima e orientação de apoios. Não reserva nem submete pedidos. A ferramenta `prepare_public_service_feedback` para o Livro Amarelo está disponível apenas no endpoint experimental `/mcp`; os plugins têm distribuição independente.

Consulte [o guia MCP e de alojamento próprio](docs/mcp.md). Contribuições são bem-vindas: [CONTRIBUTING.md](CONTRIBUTING.md). Para vulnerabilidades, veja [SECURITY.md](SECURITY.md).

## Colocar no ar

O serviço público está em [https://ecidadao.pt](https://ecidadao.pt). Cada push para `main` publica o website e o MCP após os testes passarem; veja [deploy e recuperação de versões](docs/deployment.md). Pode executar a mesma aplicação em infraestrutura própria com Docker. O guia em [docs/mcp.md](docs/mcp.md) explica a configuração local e os requisitos para HTTPS.

## Candidatura ao directório

A [submissão 0.3.1](docs/plugin-submission-0.3.1.md) foi registada como “In review” em 13 de novembro de 2026. Este é um registo histórico, não uma confirmação do estado actual. A distribuição aberta em GitHub é independente dessa candidatura. Os novos pacotes são mantidos em [ecidadao/plugins](https://github.com/ecidadao/plugins).

## Investigação de novas integrações

O [plano de capacidades](docs/support-roadmap.md) distingue funcionalidades entregues de oportunidades em investigação. Desde 0.3.4, `/municipios` pesquisa 320 entradas de Gondomar, Maia e Ponte de Lima; `/vagas` consulta atendimento presencial de Ponte de Lima; `/apoios` orienta sete percursos de habitação e ambiente em PT/EN. Veja os limites na [pesquisa municipal](docs/municipal-integrations.md) e na [pesquisa de ambiente e habitação](docs/environment-housing-discovery.md). Os dados geográficos da APA continuam em investigação.

## Estrutura do projeto

- `lib/ecidadao/complaint.ex`: validação e formatação de reclamações sem persistência.
- `lib/ecidadao/minha_rua.ex`: preparação de ocorrências e consulta das entradas públicas recentes.
- `lib/ecidadao/siga.ex`: consulta de filas públicas SIGA e comparação por distância e espera.
- `lib/ecidadao/financas.ex`: orientação para o Portal das Finanças e rascunho e-balcão.
- `lib/ecidadao/mcp.ex`: protocolo MCP e catálogo de ferramentas.
- `lib/ecidadao_web/`: site, API e endpoint HTTP.
- [ecidadao/plugins](https://github.com/ecidadao/plugins): pacotes e catálogos de instalação.
- `test/`: testes dos comportamentos críticos.

## Identidade visual

O [logótipo e símbolo](priv/static/brand/) estão disponíveis em SVG e PNG transparente, sob Apache-2.0. Pode [descarregar o pacote completo](https://ecidadao.pt/marca/ecidadao-identidade.zip). O símbolo é partilhado com os plugins.

SNS 24: `/saude` e a ferramenta pública `sns24_service_guidance` orientam consultas, exames, medicação habitual e referenciações em PT/EN. Não acedem a contas, vagas ou dados clínicos e não enviam pedidos.
