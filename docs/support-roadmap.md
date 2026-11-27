# Plano de capacidades do eCidadão

Atualizado em 27 de novembro de 2026. Este plano separa funcionalidades entregues de possibilidades dependentes de acesso autorizado. Não é uma promessa de disponibilidade das APIs inventariadas.

## Já disponível

| Capacidade | O que permite | Limite |
|---|---|---|
| Pesquisa por necessidade (`/servicos`) | Encontrar treze percursos selecionados em português e inglês | Catálogo curado; não é pesquisa nacional em tempo real no CUSP |
| Municípios (`/municipios`) | Pesquisar 320 entradas de Gondomar, Maia e Ponte de Lima | Catálogo público revisto em 27/11/2026; conclusão no portal oficial |
| Vagas (`/vagas`) | Consultar áreas, datas e horários de atendimento presencial em Ponte de Lima | Leitura pública com cache de 30 segundos; não reserva nem garante disponibilidade futura |
| Apoios (`/apoios`) | Sete percursos PT/EN de habitação e ambiente, com requisitos e fases | Sem candidatura, saldo disponível ou decisão de elegibilidade pessoal |
| SIGA assistido | Consultar informação pública de filas dentro da cobertura do adaptador e seguir para canais oficiais | Não confirma uma marcação nem garante o balcão mais próximo de todos |
| Finanças, rua e reclamações | Orientar e preparar os percursos assistidos existentes | Preparação não equivale a submissão oficial |
| Livro Amarelo | Preparar reclamação, elogio ou sugestão e abrir o canal oficial | Sem submissão por API; ferramenta apenas no MCP experimental |
| Acessibilidade de utilização | PT/EN, modo escuro automático e apresentação mobile | Testes de browser não equivalem a certificação de acessibilidade |
| Verificação de publicação | Testes de browser antes de deploy e smoke checks da publicação | Testes locais não concluem operações administrativas reais |

O catálogo público MCP passa a dez ferramentas em 0.3.4, incluindo pesquisa municipal, consulta de vagas e orientação de apoios. Uma capacidade do website ou do MCP experimental não fica automaticamente disponível nos plugins públicos. Os estados de publicação dos plugins são mantidos no seu repositório.

## Sequência proposta

| Etapa | Entrega | Dependências | Critério de conclusão |
|---|---|---|---|
| 1 — Percursos guiados | Alargar necessidades, explicar requisitos, documentos e canal correto; reforçar a distinção entre renovar, alterar morada e confirmar morada | Verificação das fontes oficiais e revisão PT/EN | Cada percurso tem fonte, data de revisão e destino oficial; não promete operações que não executa |
| 2 — Descoberta de balcões | Associar serviço e canal a locais, horários e coordenadas; filtrar proximidade | Contrato de leitura CUSP, cobertura, licença e chave; pedido técnico enviado à ARTE, a aguardar resposta | Resultados com cobertura e atualidade explícitas; sem afirmar «mais próximo» com dados incompletos |
| 3 — Marcações reais | Consultar disponibilidade, marcar e, se autorizado, consultar, alterar ou cancelar | Confirmar cobertura SIGA/IRN, contrato atual, credenciais, ambiente de testes e autorização do cidadão | Operação verificada no sistema oficial, com identificador/comprovativo; erros e duplicação tratados |
| 4 — Submissões | Enviar participações ou pedidos selecionados e acompanhar estado | API e permissão de representação próprias de cada serviço | Recibo oficial e estado verificável; rascunho nunca apresentado como submetido |
| 5 — Consultas pessoais | Avaliar carta/pontos, Segurança Social e Finanças; posteriormente outros domínios | Elegibilidade do consumidor, autorização delegada, autenticação e contrato por organismo | Âmbito mínimo autorizado, dados e sessões protegidos, revogação e testes de acesso |

As etapas 3–5 são condicionais: documentação pública não demonstra que um integrador privado tenha direito ou capacidade técnica para executar essas operações. Autenticação.gov/CMD, por si só, não concede acesso aos dados dos organismos.

## Saúde

A pedido do responsável do projeto, saúde passa a ter uma linha própria: percursos assistidos SNS 24 e informação pública de espera primeiro; filas de cuidados primários e marcações delegadas depois de confirmar acesso e cobertura com SPMS/ULS. O [plano de saúde no repositório dos plugins](https://github.com/ecidadao/plugins/blob/main/docs/health-options.md) documenta fontes, evidência técnica e dependências. A orientação SNS 24 está implementada em `/saude` e `sns24_service_guidance`; não existe acesso a contas, vagas ou submissões SNS. Tempos agregados de consultas/cirurgias não equivalem a vagas ou previsão pessoal; a comparação de urgências não substitui triagem clínica.

## Próximo trabalho independente de adesões

A [investigação de território e BUPi](territory-bupi-integrations.md) propõe guia municipal, pesquisa de metadados SNIG e piloto cartográfico DGT. Foram verificadas consultas OGC e WMS; os serviços geográficos BUPi recusaram as tentativas de capacidades neste ambiente. CRUS não serve para decidir licenciamento ou edificabilidade. Nenhuma destas propostas está ainda implementada no produto.

A [investigação de Finanças e Segurança Social](financas-social-security-integrations.md) distingue funções locais (validação estrutural IRS, documentos importados, preparação e-Clic), webservices empresariais (AT/e-Fatura, PSi) e contratos institucionais iAP. Login CMD não concede acesso geral a contas. Priorizar um registo de capacidades e um validador IRS local; pilotos privados dependem da habilitação, representação e contrato aplicáveis. Não foram usadas contas nem submetidos pedidos.

A [pesquisa municipal](municipal-integrations.md) sustenta as três capacidades implementadas em 0.3.4: catálogo municipal, orientação de apoios e consulta de vagas em Ponte de Lima. A [pesquisa de ambiente e habitação](environment-housing-discovery.md) inclui também APA/SNIAmb; a integração geográfica APA continua em investigação e não existe ferramenta pública de medições ambientais.

1. Expandir os percursos curados com base nas necessidades mais frequentes, mantendo fonte e revisão por serviço.
2. Testar e tornar explícita a cobertura das filas, incluindo a viabilidade de procura em distritos vizinhos.
3. Melhorar instruções de passagem para o portal oficial e os estados «encontrado», «preparado», «submetido» e «confirmado».
4. Manter regressões PT/EN, mobile, tema automático e rascunhos no bloqueio de publicação.

Não há prazo atribuído às integrações externas enquanto faltarem elegibilidade, contrato e acesso de testes. As 63 entradas iAP são metadados de oportunidades, não 63 serviços executáveis pelo eCidadão.

Evidência e detalhes: [oportunidades de integração](integration-opportunities.md), [pesquisa de serviços e locais](service-discovery-research.md), [pedido CUSP](cusp-access-request.md) e [testes de browser](browser-tests.md).
