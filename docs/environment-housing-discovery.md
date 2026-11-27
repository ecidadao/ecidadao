# Ambiente, apoios e Porta 65

Verificado em 27/11/2026. A versão 0.3.4 implementa sete percursos PT/EN em `/apoios` e `public_support_guidance`, incluindo Porta 65 Jovem, Porta 65+, +Habitação Gondomar, Fundo Ambiental, Vale Eficiência II, E-Lar e Mobilidade Verde. Não há candidatura submetida, acesso a contas ou monitorização recorrente ativada. APA/SNIAmb permanece em investigação.

## Oportunidades independentes

| Capacidade | Fonte | Evidência | Próxima entrega |
|---|---|---|---|
| Encontrar apoios ambientais | Fundo Ambiental, avisos PRR e eFundos | Páginas oficiais públicas, prazos e documentação | Pesquisa por finalidade e beneficiário, estado datado e checklist |
| Informação ambiental local | APA/SNIAmb | ArcGIS REST anónimo respondeu a metadados e consulta de contagem | Localizar estações/camadas, com atribuição e licença verificada |
| Licenciamento ambiental | APA/SILiAmb | Percurso oficial e simulador LUA documentados | Orientar documentos e canal; operação autenticada não implementada |
| Apoios ao arrendamento | IHRU/Porta 65 Jovem e Porta 65+ | Informação, simuladores e entrada autenticada | Triagem indicativa, documentos e passagem ao simulador oficial |
| Apoios municipais | Gondomar, Maia, Ponte de Lima | Catálogos e avisos específicos | Cruzar localidade com oportunidades sem presumir cumulabilidade |

## APA: dados e licenciamento

O [SNIAmb](https://sniamb.apambiente.pt/) reúne várias fontes ambientais. O [serviço de qualidade do ar](https://sniambgeoogc.apambiente.pt/getogc/rest/services/SNIAmb/Qualidade_do_Ar/MapServer) respondeu HTTP 200, anuncia `Map,Query,Data` e JSON/GeoJSON. A camada 0 contém estações; uma consulta anónima `returnCountOnly=true` devolveu **73 elementos**. A camada 1 contém zonas/aglomerações.

Isto prova leitura da camada geográfica, **não** medições atuais, qualidade do ar na morada do utilizador ou licença irrestrita. A página do [SNIRH](https://apambiente.pt/agua/sistema-nacional-de-informacao-de-recursos-hidricos-snirh) descreve dados de monitorização hídrica. Águas balneares, praias e risco de inundação também aparecem no catálogo SNIAmb, mas não foram testados nesta ronda. Os metadados e a contagem constam do [snapshot](municipal-discovery-2026-11-27.json).

O [LUA/SILiAmb](https://apoiosiliamb.apambiente.pt/content/acesso-ao-m%C3%B3dulo-lua?language=pt-pt) é outro produto: enquadramento de projetos, regimes ambientais, taxas e instrução eletrónica. Podemos orientar o utilizador para o simulador oficial; não encontrámos nesta pesquisa um contrato público para submeter licenças em nome do cidadão. A existência do simulador não fornece acesso delegado.

## Fundo Ambiental: estado de programas

Usar a página específica, aviso e republicações. A página [Apoios 2026](https://www.fundoambiental.pt/apoios-2026.aspx) informa que não existem formulários abertos nessa secção. Isso não demonstra que todos os percursos de execução de avisos anteriores/PRR estejam encerrados. A [lista geral](https://www.fundoambiental.pt/candidaturas/formularios.aspx) ainda colocava em «abertos» uma linha com encerramento a 20/07/2026. Marcar conflitos, não repetir cegamente o cabeçalho.

| Programa | Estado observado | O que uma integração pode fazer |
|---|---|---|
| Mobilidade Verde – Passageiros 2025/2026, segunda fase | Prazo publicado de novas candidaturas terminou a 27/07/2026; encaminha para eFundos para candidatura/estado | Explicar programa, documentação e consultar percurso de acompanhamento; não anunciar novas vagas |
| E-Lar, segunda fase | Encerrado para novas candidaturas desde a informação de 24/03/2026; pedidos de pagamento dos fornecedores até 30/11/2026 | Distinguir beneficiário de fornecedor e nova candidatura de pedido de pagamento |
| Vale Eficiência II | Novos beneficiários encerrados desde 31/10/2024. Mecanismo simplificado aberto a manifestação de interesse até 25/01/2027, apenas para beneficiários elegíveis à espera de facilitador técnico | Orientar esse público específico e localizar fornecedores qualificados por distrito/tipologia |

Fontes: [Mobilidade Verde](https://www.fundoambiental.pt/apoios-2026/mitigacao-as-alteracoes-climaticas/incentivo-pela-aquisicao-de-veiculos-de-emissoes-nulas-ano-20252026-mobilidade-verde-passageiros-2-fase.aspx), [E-Lar](https://www.fundoambiental.pt/apoios-prr/c13-eficiencia-energetica-em-edificios/11c13-i012025-programa-e-lar-2-fase.aspx), [Vale Eficiência II](https://www.fundoambiental.pt/apoios-prr/c13-eficiencia-energetica-em-edificios/06c13-i01-programa-vale-eficiencia-ii.aspx).

Não foi confirmada uma API pública de candidaturas ou de saldo remanescente. Uma dotação ou número original de incentivos não é disponibilidade atual. Não subtrair candidaturas apresentadas à dotação para inventar vagas: podem existir avaliações, desistências, reservas e redistribuições.

Modelo proposto por aviso/fase: `source_url`, `verified_at`, `audience`, `purpose`, `application_opens_at`, `application_closes_at`, `status`, `status_evidence`, `budget_total`, `remaining_budget=null` quando não confirmado, `application_url`, `authentication`, `documents`, `supersedes`. Estados distintos: anunciado, aberto, encerrado, esgotado confirmado, execução/pagamento, desconhecido/conflito. Uma data ultrapassada bloqueia o rótulo aberto salvo prorrogação documentada.

Alertas seriam úteis para reabertura, prazo próximo, documentos em falta e manifestação de interesse. Não foi criada automação nesta investigação; frequência e destinatários pertencem à implementação e escolha do utilizador.

## Porta 65 Jovem

O [programa oficial](https://www.portaldahabitacao.pt/porta-65-jovem) apoia arrendamento jovem e prevê candidatura sem contrato. A avaliação não pode limitar-se à idade: agregado, rendimentos, renda, localização, outros imóveis, relação com senhorio e apoios existentes são relevantes. A candidatura tem autenticação dos participantes nos termos do [percurso oficial](https://www.portaldahabitacao.pt/como-se-candidatar-porta65jovem).

A página de [novas candidaturas](https://www.portaldahabitacao.pt/web/guest/o-que-e-porta65jovem) explica documentação do contrato registado na AT, rendimentos e comprovativos alternativos. Podemos preparar uma checklist personalizada e orientar para o simulador. Não reproduzir já uma fórmula de aprovação/valor: existem páginas históricas ainda indexadas e regras alteradas em 2024, nomeadamente a candidatura sem contrato e a distinção entre limite de exclusão e renda de referência para cálculo.

Uma futura simulação própria precisa de regras e tabelas atuais, versão e testes contra casos oficiais. A aprovação, o montante e o pagamento são atos diferentes. Candidatura sem contrato não significa pagamento sem contrato.

## Porta 65+

O [Porta 65+](https://www.portaldahabitacao.pt/web/guest/porta-65mais) tem modalidades para quebra de rendimentos superior a 20% e famílias monoparentais, independentemente da idade, com requisitos adicionais. A página ainda ilustra um limite de rendimento com valor de 2023: não transpor esse montante para 2026 sem verificar a regra vigente.

Há [simulador público](https://www.portaldahabitacao.pt/porta65m/simulador/habitacaoArrendadaSimulador) e páginas próprias para [perda de rendimentos](https://www.portaldahabitacao.pt/web/guest/candidatura-perda-de-rendimento) e [família monoparental](https://www.portaldahabitacao.pt/web/guest/candidatura-monoparental1). Seguir a candidatura por perda de rendimentos redirecionou para autenticação com CC/CMD ou AT. Não foi feita simulação numérica nem login. Não há prova de API pública de submissão ou consulta pessoal de estado.

As listas públicas de resultados são uma fonte diferente da área pessoal. Evitar recolha massiva de dados de candidatos; orientar o próprio para consulta oficial. O acompanhamento via MCP só deve declarar recebido/aprovado/pago com evidência oficial correspondente.

## Produto proposto

1. **Descoberta de apoios:** habitação, energia, mobilidade e apoios municipais; filtrar município, tipo de beneficiário e necessidade, sem pedir NIF/IBAN para pesquisar.
2. **Triagem indicativa:** perguntas mínimas e critérios com fonte; resultado «pode enquadrar-se», «falta informação» ou «não cumpre este critério», nunca aprovação administrativa.
3. **Preparação:** checklist, documentos em falta e destino oficial. Alertar para cumulação apenas com regras verificadas dos programas em causa.
4. **Operações futuras:** autenticação no portal, submissão e recibo. Não expor credenciais fiscais ao modelo nem confundir um formulário preparado com candidatura entregue.

Nomes de ferramentas candidatos, ainda não implementados: `find_public_support`, `public_support_guidance`, `housing_support_guidance`, `environmental_data_lookup`. Não precisam de parceria com outro fornecedor de IA; acesso transacional depende dos portais/organismos responsáveis.
