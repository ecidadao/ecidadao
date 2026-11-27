defmodule Ecidadao.ServiceDirectory do
  @moduledoc """
  Curated navigation, not a live service index.
  Official links checked against their gov.pt service pages on 2026-11-27.
  No runtime requests or user data are needed to browse this catalogue.
  """
  @services [
    %{
      id: "health",
      title: "Consultas, exames e serviços SNS 24",
      description:
        "Veja como pedir consultas, exames e renovação de medicação ou acompanhar referenciações. Os pedidos são feitos nos canais oficiais.",
      aliases:
        "saude sns sns24 consulta consultas centro hospital exames exame analises medicamento medicamentos medicacao renovar renovacao receita receitas referencias referenciacoes health healthcare appointment appointments tests exams prescription prescriptions medication referral referrals",
      url: "/saude",
      official: false
    },
    %{
      id: "cc-renewal",
      title: "Renovar o Cartão de Cidadão",
      description: "Veja no gov.pt as opções de renovação e os requisitos atuais.",
      aliases:
        "renovar renovacao cartao cidadao cc validade caducado renew renewal citizen card expired",
      url: "https://www.gov.pt/servicos/renovar-o-cartao-de-cidadao",
      official: true
    },
    %{
      id: "cc-address",
      title: "Alterar a morada do Cartão de Cidadão",
      description: "Consulte como pedir a alteração de morada no portal oficial.",
      aliases: "alterar mudar mudanca morada cartao cidadao cc change move address citizen card",
      url: "https://www.gov.pt/servicos/alterar-a-morada-do-cartao-de-cidadao",
      official: true
    },
    %{
      id: "cc-address-confirmation",
      title: "Confirmar a alteração de morada",
      description: "Consulte o passo de confirmação e os requisitos no gov.pt.",
      aliases:
        "confirmar confirmacao alterar alteracao morada carta codigo cartao cidadao cc confirm confirmation address change letter code",
      url: "https://www.gov.pt/servicos/confirmar-a-alteracao-de-morada-do-cartao-de-cidadao",
      official: true
    },
    %{
      id: "siga",
      title: "Marcação e filas de atendimento",
      description:
        "Consulte os percursos SIGA no eCidadão. A marcação é feita no portal oficial; a disponibilidade depende do serviço.",
      aliases:
        "marcar marcacao agendar agendamento atendimento filas senha siga irn booking appointment appointments queue queues ticket",
      url: "/siga",
      official: false
    },
    %{
      id: "financas",
      title: "Esclarecer uma questão fiscal",
      description:
        "Encontre orientação e prepare um rascunho para o e-balcão. Reveja e envie no Portal das Finanças.",
      aliases:
        "financas impostos imposto fiscal irs imi duvida questao ebalcao balcao tax taxes question help",
      url: "/financas",
      official: false
    },
    %{
      id: "tax-certificates",
      title: "Pedir uma certidão fiscal",
      description:
        "Consulte no gov.pt como pedir uma certidão de dívida ou não dívida às Finanças.",
      aliases:
        "certidao certidoes fiscal financas divida nao comprovativo tax certificate certificates debt proof",
      url: "https://www.gov.pt/servicos/pedir-certidao-de-divida-ou-nao-divida-as-financas",
      official: true
    },
    %{
      id: "street-report",
      title: "Reportar um problema na rua",
      description:
        "Consulte ocorrências públicas e prepare um reporte no eCidadão. O envio é feito em A Minha Rua; confirme a cobertura oficial.",
      aliases:
        "rua buraco lixo iluminacao passeio ocorrencia reportar problema street pothole rubbish lighting pavement public space report",
      url: "/a-minha-rua",
      official: false
    },
    %{
      id: "consumer-complaint",
      title: "Reclamar de uma empresa",
      description:
        "Prepare um rascunho de reclamação de consumo. A apresentação é feita no Livro de Reclamações Eletrónico.",
      aliases:
        "reclamar reclamacao reclamacoes consumidor consumo empresa compra loja complain complaint complaints consumer business purchase shop",
      url: "/reclamacoes",
      official: false
    },
    %{
      id: "public-feedback",
      title: "Reclamar, elogiar ou sugerir a um serviço público",
      description:
        "Prepare um rascunho para o Livro Amarelo. A submissão à entidade pública é feita no gov.pt.",
      aliases:
        "reclamar reclamacao reclamacoes elogio elogiar sugestao sugerir publico servico livro amarelo complain complaint complaints public service feedback compliment suggestion",
      url: "/livro-amarelo",
      official: false
    }
  ]
  def all, do: @services
end
