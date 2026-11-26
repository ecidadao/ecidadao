# Publicação em produção

O website, as APIs e o MCP são publicados a partir de `ecidadao/ecidadao`. Os plugins são distribuídos separadamente em `ecidadao/plugins`.

## Fluxo automático

1. Um push para `main` executa os testes em GitHub Actions.
2. Se passarem, o job `deploy` usa o environment `production` e uma chave SSH dedicada.
3. O servidor descarrega o código do commit exacto e constrói `ecidadao-release:<SHA>`.
4. Um contentor temporário, acessível apenas por loopback, valida páginas, imagens, saúde e o catálogo MCP público.
5. A aplicação é substituída e verificada novamente, incluindo por HTTPS público. Se a verificação falhar, o script restaura a imagem anterior.

A substituição pode causar uma breve interrupção. O Caddy e as outras aplicações no servidor não são alterados. A concorrência é controlada no workflow e por `flock` no servidor.

`GET /health` inclui `revision`, o SHA publicado. O histórico dos jobs e deployments fica no GitHub. Pull requests executam testes sem acesso ao deploy.

## Configuração do servidor

- `/opt/ecidadao/shared/.env`: segredos existentes, preservados fora do Git.
- `/opt/ecidadao/deploy/compose.production.yaml`: configuração de produção.
- `/opt/ecidadao/deploy/smoke.py`: verificações da aplicação.
- `/usr/local/sbin/ecidadao-deploy`: cópia de `deploy/deploy.sh`, propriedade de root.
- `/opt/ecidadao/deploy/revision` e `previous-revision`: versão actual e anterior.
- Imagens Docker `ecidadao-release:<SHA>`: versões disponíveis para recuperação.

A chave do utilizador `ecidadao-deploy` tem um comando SSH forçado e não permite terminal ou encaminhamento. O sudo permite apenas o script de deploy, que aceita `deploy <SHA>` ou `rollback <SHA>` com um SHA hexadecimal completo. O código em `main` continua a ser código de confiança: o Dockerfile é executado no servidor.

Os secrets do environment `production` são `DEPLOY_HOST`, `DEPLOY_KNOWN_HOSTS` e `DEPLOY_SSH_KEY`. A chave do host é obtida por uma ligação administrativa já verificada. Alterações ao script de deploy, ao Compose de produção ou ao verificador devem ser instaladas pelo administrador nos caminhos acima; o deploy da aplicação não substitui esses ficheiros administrativos.

## Voltar a uma versão

Escolha um SHA anteriormente publicado e ainda disponível nas imagens locais. Usando a chave dedicada:

```sh
ssh -i /caminho/para/chave ecidadao-deploy@SERVIDOR "rollback SHA_COMPLETO"
```

O rollback também testa a imagem antes da troca e confirma o serviço por HTTPS. Para publicar novamente `main`, execute o workflow manualmente no separador Actions. Não elimine as imagens actual e anterior durante limpezas do Docker.

Para voltar à versão anterior ao primeiro deploy automático, o servidor conserva a imagem `ecidadao-release:bootstrap` e a instalação original em `/opt/ecidadao/current`. Esta recuperação excepcional exige acesso administrativo.
