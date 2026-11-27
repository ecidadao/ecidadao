# Integrações municipais: Gondomar, Maia e Ponte de Lima

Pesquisa de 27 de novembro de 2026. Estado: **descoberta e provas de leitura**, sem novas ferramentas publicadas no MCP. Não foram criadas reservas, candidaturas ou contas. As consultas não usaram dados pessoais do responsável do projeto.

## Resultado técnico

| Município | Evidência obtida | Entrega independente viável | Limite |
|---|---|---|---|
| Gondomar | Menu JSON anónimo: 17 áreas, 165 nós visíveis, 135 entradas finais | Pesquisa de serviços por necessidade, percurso, documentos e passagem ao formulário | Menu do frontend, não contrato de API; entrada final pode ser consulta, junção ou alteração, não serviço executável autónomo |
| Maia | Diretório A–Z: 211 links únicos, 168 caminhos sem query string; inclui categorias e variantes de ação | Catálogo, ocorrências, requisitos, apoios, encaminhamento para GMA/BUPi | Não anunciar 211 serviços. A página GMA respondeu que não havia datas na observação direta |
| Ponte de Lima | 58 links de procedimentos e endpoints JSON de áreas, datas e horários | Pesquisa de procedimentos e protótipo de leitura de disponibilidade de atendimento | API usada pelo site, sem contrato público de suporte/reutilização confirmado; submissão não testada |

O [snapshot JSON](municipal-discovery-2026-11-27.json) conserva títulos, destinos, metadados e horários públicos. O [probe](../scripts/probe_municipal_services.py) permite repetir as leituras: `python3 scripts/probe_municipal_services.py --output /tmp/municipal-discovery.json`. Não grava cookies, tokens CSRF, HTML integral ou candidaturas. Falhas são registadas e produzem exit code diferente de zero.

## Gondomar: cobertura do menu público

Inventário integral dos nós visíveis no menu anónimo; não é auditoria completa dos serviços autenticados, empresas municipais ou serviços presenciais. A fonte é a chamada usada pelo JavaScript público `MenuMyNetMobileLess.js`:

`https://servicosonline.cm-gondomar.pt/MyNetMenuExterno.asp?publico=1&objecto=json&raiz=Todos%20Sercicos%20Online&frame=1`

| Área | Entradas finais |
|---|---:|
| Urbanismo | 52 |
| Atividades Económicas | 12 |
| Ocupação do Espaço Público | 9 |
| Apoio ao Munícipe | 8 |
| Apoio Social | 8 |
| Licenças e taxas | 8 |
| Mobilidade, Trânsito e Transportes | 7 |
| Publicidade | 7 |
| Certidões e Outros Documentos | 6 |
| Recursos Humanos | 5 |
| A sua opinião | 3 |
| Área do Cidadão | 2 |
| Atividades Sociais | 2 |
| Contraordenações Rodoviárias | 2 |
| Habitação | 2 |
| Ambiente | 1 |
| Equipamentos Municipais | 1 |

Prioridades para utilização quotidiana:

- **Habitação e apoios:** +Habitação, entrega de documentos/comprovativos, tarifário especial da água, Natal Solidário, atualização da renda municipal e acordo de pagamento. O catálogo distingue pedido inicial e junção de documentos; não os deve fundir.
- **Atendimento e participação:** atendimento técnico, audiências, inscrição em reunião pública e opinião do munícipe. Pedido de atendimento não demonstra consulta de vagas nem confirmação imediata.
- **Mobilidade:** emissão/renovação do cartão de estacionamento residente/comerciante, reserva para deficiência motora e lugares privados. Instruções assistidas primeiro.
- **Documentos:** requerimento geral, certidões e fotocópias. Verificar autenticação, assinatura e taxas em cada ficha.
- **Ambiente:** recolha de águas residuais no portal. A [recolha de monos](https://www.cm-gondomar.pt/atividade-municipal/ambiente/monos/) tem agendamento telefónico publicado; não inferir um formulário comum aos dois serviços.
- **Urbanismo:** PIP, licenciamento, comunicações, início de obra, utilização, averbamentos, propriedade horizontal e certidões. Pesquisa e preparação têm valor; submissões exigem instrução e, conforme o pedido, documentos assinados/técnicos.
- **Equipamentos e associações:** cedência GoldPark e outros portais institucionais são vias distintas; não há prova de inventário de disponibilidade em tempo real.

O menu identifica `requerautenticacao=true` para atendimento técnico, +Habitação, tarifário especial da água e requerimento geral. Guardamos o valor original e o dos antecessores; a marcação do menu não substitui uma verificação do formulário. A [FAQ oficial](https://servicosonline.cm-gondomar.pt/srv.gondomarresponsivo/FAQ.html) explica registo validado, formulários com e sem conta, consulta de processos e conta corrente. Não foi explorada qualquer conta pessoal.

**Oportunidade com prazo próximo:** o aviso municipal de 3/11/2026 anuncia a segunda fase de +Habitação até **30/11/2026**, para encargos com renda ou crédito, e aponta candidatura online, presencial ou por correio. A notícia indica residência no concelho há pelo menos seis meses e encargo mensal de pelo menos 150 euros; estes dois pontos não são uma avaliação completa de elegibilidade. Não confundir com o programa separado de arrendamento de habitações municipais. [Aviso](https://www.cm-gondomar.pt/abertas-candidaturas-a-2-a-fase-do-apoio-ao-arrendamento-e-credito-a-habitacao/).

Complementos encontrados no [portal institucional](https://www.cm-gondomar.pt/balcao-virtual/): educação, bibliotecas, piscinas, apoio ao associativismo, animais, mapas/PDM e simulador de taxas. Ainda não foram validadas APIs, reservas, pagamentos ou estados pessoais nestes portais.

## Maia

O [diretório A–Z](https://diretorio.cm-maia.pt/todos-os-servicos-de-a-a-z) permite pesquisar informação pública estruturada por necessidade. Contém variantes consultar/pedir/pagar e links de categoria, pelo que requer normalização antes de entrar num catálogo de produção.

- [Agendamento municipal](https://www.cm-maia.pt/agendamentos-e-marcacoes): GMA e BUPi. A página esclarece que GMA recebe requerimentos; atendimento técnico com arquitetos é solicitado por email próprio. Não encaminhar todos os assuntos de urbanismo para a mesma marcação.
- [GMA](https://www.cm-maia.pt/institucional/atendimento-e-pedidos/atendimento-municipal/agendamentos/gma-atendimento-municipal): a resposta HTTP direta da investigação apresentou ausência de datas. A cópia indexada ainda apresentava o formulário. Usar leitura atual, não snippets de pesquisa, para disponibilidade.
- [Ocorrências](https://diretorio.cm-maia.pt/diretorio-de-servicos/directorio_de_servicos/registo-de-ocorrencias): permite descrever problema, localização e fotografias facultativas. A participação de sinistro é outro percurso. Um relato de ocorrência não equivale a pedido de indemnização.
- Recolha de monos pertence à **Maiambiente**; o diretório encaminha para a empresa municipal. É necessário um adaptador próprio ou passagem ao seu canal.
- Candidatura a habitação social, bolsas, tarifários sociais de água/saneamento/resíduos e MAIA ENERGY HUB são boas entradas para o motor de descoberta de apoios. A presença da ficha não demonstra candidatura aberta ou verba disponível.

Há diferenças entre horários do diretório e páginas institucionais atualizadas. Para locais e horas, preferir a ficha específica mais recente e conservar data/fonte, incluindo a mudança do GMA para a Loja do Cidadão indicada pelo município.

## Ponte de Lima

O [diretório novo](https://www.cm-pontedelima.pt/diretorio-de-servicos) respondeu «Brevemente Disponível». Contudo, a página de [formulários dos Serviços Online](https://www.cm-pontedelima.pt/servicos/apoio-ao-municipe/servicos-online/formularios) já lista procedimentos: urbanismo, certidões, ação social escolar, transportes escolares, bolsas, viaturas, incentivo à produção pecuária e recolha de volumosos/REEE. O antigo domínio de serviços redireciona para o site municipal. A integração embebida identifica SIGMA/Medidata; não inferir compatibilidade com MyNet de Gondomar.

O formulário de [agendamentos](https://www.cm-pontedelima.pt/pages/1606) usa estes GET públicos, lidos sem autenticação:

1. `/api/v1/appointments/get_avaible_customer_areas?appointment_type=in_person&allowed=` — cinco áreas de atendimento na observação.
2. `/api/v1/appointments/get_available_dates?customer_service_area_id=7&appointment_type=in_person&operator_id=` — datas e configuração dos campos.
3. `/api/v1/appointments/get_empty?customer_service_area_id=7&start_at_date=02%2F12%2F2026&appointment_type=in_person&operator_id=` — quatro horários públicos.

Para **Consulta de Processo sem Técnico – DOP**, a consulta de 27/11 devolveu 2/12/2026 às 09:30, 10:30, 11:30 e 15:30, em períodos de uma hora. Isto é uma observação histórica, não uma reserva ou garantia de disponibilidade futura. A configuração da área exige telemóvel e NIF, apesar de o HTML genérico poder apresentar opcionalidade diferente. O formulário inclui proteção reCAPTCHA; não foi ultrapassada nem feita submissão.

É a melhor hipótese encontrada para um protótipo de **consulta real de vagas municipais**. Antes de produção: validar condições de uso, limitar chamadas e cobertura, revalidar horário no portal e devolver `available_at_check_time`, nunca `booked`. Marcação assistida exige confirmação oficial, tratamento de duplicação e intervenção do utilizador quando o portal a exigir.

## Prioridade de implementação

1. Catálogo municipal normalizado: município, necessidade, categoria, ação, fonte, data, autenticação e estado de integração. Gondomar primeiro, seguido de Maia e Ponte de Lima.
2. `municipal_service_guidance`: requisitos verificados para um conjunto pequeno de serviços prioritários; não gerar instruções genéricas para todas as entradas.
3. Piloto de `municipal_appointment_availability` em Ponte de Lima, inicialmente só leitura e cobertura explícita. A mesma aparência do site da Maia não prova uma API idêntica.
4. Preparação local de ocorrências e pedidos, com passagem ao formulário e recibo apenas quando realmente obtido.
5. Apoios à habitação/energia associados ao município: ver [apoios ambientais e Porta 65](environment-housing-discovery.md).

Braga mantém a investigação da app Balcão Único Senhas; não foi testada emissão de senhas nesta ronda. Porto/Lisboa mantêm a oportunidade de dados abertos. Não há novo compromisso de parceria nem pedido de acesso enviado.
