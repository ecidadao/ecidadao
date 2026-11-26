# SIGA: interfaces de consulta observadas

Investigação de 9 de novembro de 2026 sobre o [portal SIGA](https://siga.marcacaodeatendimento.pt/). Foram feitos apenas pedidos de leitura e navegação até à apresentação de vagas. Não foi emitida nenhuma senha nem criada uma marcação.

## Resultado

Não encontrei documentação de uma API pública de integração para marcações ou senhas. O portal tem, porém, chamadas internas usadas pelo seu próprio frontend. As seguintes responderam sem autenticação num teste pontual:

| Função | Chamada observada | Resposta |
| --- | --- | --- |
| Pesquisar assuntos | `POST /Marcacao/PesquisaAssuntos` | JSON com entidade, tema, subtema, motivo, identificadores e indicação de autenticação |
| Localidades para um assunto e distrito | `POST /Marcacao/PesquisaLocalidades` | JSON com concelhos e opção «todas as localidades» |
| Entidades com filas num distrito | `POST /Senhas/GetEntidadesNoDistrito` | JSON com identificadores e nomes |
| Tipos de senha da entidade | `POST /Senhas/GetSenhas` | JSON com identificadores e nomes |
| Balcões e estado das filas | `POST /Senhas/GetLocais` | JSON com balcão, morada, latitude, longitude, distância, pessoas em espera, tempo de espera, estado e disponibilidade de senha web |

Os parâmetros e nomes de campos foram verificados no HTML e no JavaScript das páginas [Pesquisar assunto](https://siga.marcacaodeatendimento.pt/Marcacao/PesquisaAssunto) e [Consultar filas](https://siga.marcacaodeatendimento.pt/Senhas/TemposEspera). A consulta de balcões foi testada para um distrito, uma entidade e um tipo de senha, com resposta JSON. Quando não se fornece localização, o campo de distância pode conter um valor sentinela; as coordenadas dos balcões permitem calcular a distância em linha reta a partir da origem fornecida pelo utilizador.

Para vagas de marcação, o percurso observado foi selecionar um assunto, escolher atendimento presencial e selecionar um distrito. A página `GET /Marcacao/HorarioDistrito` devolveu sugestões de vagas com data, hora e local, incorporadas no HTML. Ainda não foi identificada uma chamada JSON independente que liste todas as vagas de todos os balcões. As sugestões da página podem ser parciais; por isso, não sustentam por si só a afirmação de que uma vaga é a primeira disponível em todo o raio pedido.

A página [Consultar filas](https://siga.marcacaodeatendimento.pt/Senhas/TemposEspera) também apresenta o percurso «Tirar senha», com envio e validação de código por email. Não testei essas operações porque emitem uma senha. Algumas entidades ou assuntos exigem autenticação; a pesquisa de assuntos inclui esse indicador. A conclusão de uma marcação pode exigir autenticação, validação ou CAPTCHA.

## Implicações para o eCidadão

Uma primeira ferramenta MCP de **consulta de filas** é tecnicamente viável: receber origem, raio, entidade e serviço; consultar balcões; filtrar por distância; devolver estado e hora da observação. O cálculo de «mais rápido hoje» precisa ainda de tempo de deslocação e deve distinguir estimativas de espera de horários garantidos.

Uma ferramenta de **primeira vaga de marcação** precisa de mais validação. A página de sugestões permite provar que há dados de vagas acessíveis antes da submissão, mas falta verificar cobertura, paginação, estabilidade e limites de consulta. Não se deve publicar uma comparação anunciada como exaustiva sem essa verificação.

Estas rotas são detalhes internos do portal, sujeitos a alterações e sem contrato de compatibilidade identificado. Antes de depender delas num serviço público, confirmar condições de reutilização e limites de acesso com o operador do SIGA, o [Instituto de Informática, I.P.](https://siga.marcacaodeatendimento.pt/SobreOSiga/SobreOSiga). O Work pode usar a interface normal do portal como percurso assistido enquanto a integração formal é esclarecida.
