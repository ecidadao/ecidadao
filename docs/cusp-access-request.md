# Pedido técnico CUSP — enviado

Estado: pedido de esclarecimento enviado à ARTE, para `conteudos@arte.gov.pt`, com autorização do responsável do projeto. Aguarda resposta. O envio não constitui adesão, compromisso de custos ou autorização de integração. O texto abaixo conserva a proposta técnica e as referências internas; não é uma transcrição exata do email.

**Assunto: Acesso de consumo ao CUSP para descoberta de serviços e locais de atendimento — eCidadão**

Bom dia,

Estamos a avaliar a integração do CUSP no eCidadão para ajudar as pessoas a encontrar o serviço público adequado, compreender requisitos e passos, identificar locais de atendimento e seguir para o canal oficial. Pretendemos apenas consultar informação pública de catálogo, sem criar ou alterar registos e sem aceder a dados pessoais ou executar serviços em nome do cidadão.

O caso inicial é distinguir os vários serviços de Cartão de Cidadão e encontrar os locais que os prestam perto de Rio Tinto. Precisamos de distinguir, por exemplo, renovação assistida num Espaço Cidadão e atendimento presencial num balcão do IRN, conservando os requisitos de cada canal.

Consultámos a documentação da API pública CUSP e verificámos que o portal gov.pt disponibiliza publicamente resultados de pesquisa e detalhes de serviços e locais. Gostaríamos de usar um contrato de consumo suportado e esclarecer as condições aplicáveis:

1. Uma entidade privada como o eCidadão pode aderir como consumidora exclusivamente de leitura do catálogo nacional? Que requisitos, documentação, NIPC, custos e instrumentos de adesão se aplicam, sem assumir o papel de entidade prestadora ou editora?
2. Qual é a versão atual do OpenAPI e quais são os URLs de pré-produção e produção? Como são emitidas e renovadas as chaves, que scopes de leitura existem e quais são os critérios de testes e passagem a produção?
3. O acesso inclui serviços, entidades, balcões, moradas, coordenadas, horários, exceções de funcionamento, requisitos, documentos, custos, prazos, passos e URLs dos canais oficiais? Que campos podem estar ausentes e qual a cobertura de Portugal continental, regiões autónomas e postos consulares?
4. Como se consulta a associação entre um serviço, um canal e um ponto de atendimento? Há distinção estruturada entre apoio à realização online, atendimento presencial completo, recolha de biometria e levantamento, incluindo restrições específicas por balcão?
5. Existe correspondência oficial entre os identificadores `CES:SRV:…`, `CES:POC:…` e `SIOE:ORG:…` publicados pelo gov.pt e os identificadores `SRV-…`, `POC-…` e `ORG-…` documentados no CUSP? Esses identificadores são estáveis entre versões e ambientes?
6. Que filtros existem por texto, serviço, entidade, canal, distrito, concelho e distância? Qual é a semântica do raio e da ordenação geográfica, o sistema de coordenadas, o limite por página e o mecanismo de paginação completa?
7. Como consultar alterações incrementais, datas efetivas, versões, encerramentos e registos eliminados? Qual a frequência de atualização entre as entidades, o CUSP e o índice do gov.pt, e que data representa a revisão de cada campo?
8. Quais são as quotas, concorrência permitida, limites de exportação, SLA, cabeçalhos de cache, política de retry e procedimentos de aviso de alterações de contrato? Existem traduções e um locale normalizado?
9. É autorizada a apresentação e indexação dos dados num site e em respostas MCP, incluindo eventual utilização comercial, resumos e traduções? Que licença, atribuição, cache, retenção, redistribuição e uso de marcas se aplicam? Os termos gerais do gov.pt limitam a reutilização a finalidades não lucrativas; precisamos de esclarecer o regime específico dos dados CUSP.
10. Enquanto decorre a adesão, há um endpoint público suportado ou um conjunto de dados oficialmente licenciado para esta finalidade? O endpoint de pesquisa utilizado pelo frontend gov.pt, `/api/post-search-result`, pode ser consumido por terceiros ou deve ser reservado ao portal?

Não pretendemos que este pedido autorize marcações ou acesso a dados pessoais. Qualquer integração transacional será tratada separadamente, com o operador e os requisitos próprios.

Agradecemos a indicação do percurso de adesão adequado e da documentação técnica necessária para preparar o protótipo de consumo.

Referências para acompanhamento interno: [API CUSP](https://guias.mosaico.gov.pt/plataformas-comuns-da-administracao-publica/catalogo-unico-de-servicos-publicos-cusp/quais-os-pre-requisitos-tecnicos-de-adesao/api-publica-do-cusp), [adesão](https://guias.mosaico.gov.pt/plataformas-comuns-da-administracao-publica/catalogo-unico-de-servicos-publicos-cusp/qual-o-processo-de-adesao), [termos gov.pt](https://www.gov.pt/termos-e-condicoes), [evidência técnica local](service-discovery-research.md).
