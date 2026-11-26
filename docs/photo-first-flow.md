# Percurso principal: fotografar e reportar no ChatGPT

## Experiência pretendida

1. A pessoa abre o eCidadão no ChatGPT e tira ou anexa uma fotografia. Pode dizer apenas «Quero reportar isto».
2. O ChatGPT descreve o que é visível, sem inventar causa, identidade, data ou local. O plugin devolve uma prévia curta e sugere o percurso: espaço público, serviço público ou consumo. Se não houver evidência suficiente, pergunta o tipo de local.
3. Um cartão da app pede **Usar localização**. A localização precisa só é recolhida depois de uma ação explícita. A pessoa confirma a rua, edifício ou ponto no mapa; a localização aproximada da conversa serve apenas como pista.
4. A pessoa vê a fotografia, o local, a entidade de destino e o texto sugerido. Corrige em linguagem natural e confirma o envio.
5. O eCidadão envia pelo canal oficial apenas quando existir integração autorizada e devolve o comprovativo ou identificador emitido por esse canal. Até lá, apresenta uma prévia e encaminha para o formulário oficial, sem afirmar que enviou.

## O que já está implementado

- `preview_photo_report` recebe uma descrição factual produzida pelo ChatGPT a partir da fotografia e sugere o canal e a próxima pergunta.
- `open_report_camera` expõe um cartão MCP Apps local para escolher ou tirar a fotografia e pedir localização após toque explícito. O cartão foi testado num navegador com as APIs do host simuladas; ainda falta testá-lo no ChatGPT móvel real.
- Usa apenas cidade/região/país da indicação aproximada opcional `_meta["openai/userLocation"]`; ignora coordenadas e mantém `location_confirmed: false`.
- `prepare_complaint`, formulário A Minha Rua e consulta de ocorrências recentes continuam disponíveis na versão local.
- Nenhuma fotografia, coordenada precisa ou rascunho é guardado no servidor e não há submissão oficial.

## Trabalho para a experiência móvel

- Testar o componente MCP Apps no ChatGPT móvel real. O recurso pede as permissões `camera` e `geolocation`, mas o host pode recusá-las; a seleção de imagem e a indicação manual do local funcionam como alternativa.
- Associar a fotografia escolhida ao modelo através dos mecanismos de ficheiros do ChatGPT; quando uma integração oficial exigir o original, usar um parâmetro de ficheiro autorizado e tratar o ficheiro apenas para esse envio.
- Converter a localização confirmada num recurso temporário consentido, referenciado pela app. A ferramenta MCP pública não deve pedir coordenadas ou morada como argumentos livres.
- Confirmar no ChatGPT móvel real a câmara, geolocalização, mapa, revisão e acessibilidade. O funcionamento do navegador local não garante as permissões no host.
- Para A Minha Rua, pedir à ARTE uma via de integração documentada que permita anexar imagem e obter o número do pedido. O formulário atual exige identificação, consentimento e reCAPTCHA; não automatizar nem contornar essa verificação.
- Para outros serviços, manter encaminhamento por entidade e canal verificado; não escolher automaticamente um órgão público apenas pela fotografia.

## Critérios de aceitação

- Uma foto e um toque em «Usar localização» devem chegar a uma prévia editável, quando o host conceder a permissão.
- Se a permissão for recusada, a pessoa consegue indicar o local sem perder a fotografia nem o texto.
- A localização e a entidade são confirmadas antes de qualquer envio.
- O estado «enviado» só aparece após resposta verificável do canal oficial.
- O original da fotografia só é transmitido ao destinatário após consentimento explícito e com política de conservação definida.

Fontes técnicas: [ficheiros em plugins ChatGPT](https://developers.openai.com/plugins/reference), [permissões de recursos MCP Apps](https://apps.extensions.modelcontextprotocol.io/api/interfaces/app.McpUiResourcePermissions.html), [regras de localização em plugins](https://developers.openai.com/plugins/plugin-guidelines). Fontes do serviço: [formulário A Minha Rua](https://servicos.arte.gov.pt/Portal/AMR/situationReport.aspx), [termos A Minha Rua](https://www.gov.pt/termos-e-condicoes/termos-e-condicoes-a-minha-rua).
