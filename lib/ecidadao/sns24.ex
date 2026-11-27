defmodule Ecidadao.Sns24 do
  @moduledoc "Curated SNS 24 guidance. No account access, clinical triage or external requests."
  @routes [
    %{
      id: "appointments",
      source: "https://www.sns24.gov.pt/pt/servico/marcacao-de-consultas/",
      pt: %{
        title: "Pedir consulta no centro de saúde",
        requirements:
          "É necessário estar inscrito numa unidade de saúde que disponibilize vagas no SNS 24.",
        portal:
          "Inicie sessão no Portal SNS 24. Abra Consultas e referenciações → Marcação de consultas → Marcar consulta. Escolha o tipo e um horário disponível, reveja e confirme o pedido.",
        app:
          "Na App SNS 24, abra Consultas e referenciações → Marcação de consultas → Marcar consulta. Escolha o tipo e horário, reveja e confirme o pedido.",
        confirmation:
          "O pedido é enviado à unidade. Confirme no histórico que a consulta está Agendada antes de a considerar marcada. A disponibilidade depende da unidade; este percurso não garante consulta para amanhã.",
        alternative:
          "Se não encontrar vagas ou o serviço, contacte a sua unidade de saúde ou procure apoio num Balcão SNS 24. Para avaliação de sintomas, utilize os canais clínicos oficiais do SNS 24."
      },
      en: %{
        title: "Request a health centre appointment",
        requirements:
          "You must be registered at a health centre that offers appointments through SNS 24.",
        portal:
          "Sign in to the SNS 24 portal. Open Consultas e referenciações → Marcação de consultas → Marcar consulta. Choose the appointment type and an available time, review and confirm the request.",
        app:
          "In the SNS 24 app, open Consultas e referenciações → Marcação de consultas → Marcar consulta. Choose the type and time, review and confirm the request.",
        confirmation:
          "The request is sent to your health centre. Check that its status is Agendada (scheduled) before treating it as confirmed. Availability depends on the unit; this route does not guarantee an appointment tomorrow.",
        alternative:
          "If there are no slots or the service is unavailable, contact your health centre or an SNS 24 desk for help. For symptom assessment, use the official SNS 24 clinical channels."
      }
    },
    %{
      id: "exams",
      source: "https://www.sns24.gov.pt/pt/servico/exames-e-resultados/",
      pt: %{
        title: "Pedir exames perto de si",
        requirements:
          "Precisa de uma requisição eletrónica ativa com exames elegíveis. São apresentados prestadores convencionados para os exames selecionados.",
        portal:
          "No Portal SNS 24, abra Receitas e exames → Exames e escolha a requisição. Selecione Pedir agendamento de exames, os exames e o distrito/concelho. Escolha o prestador, confirme a morada e reveja antes de submeter.",
        app:
          "Na App SNS 24, abra Receitas e exames → Exames, escolha a requisição e Pedir agendamento de exames. Indique distrito/concelho ou use Ver entidades perto de mim, permitindo localização na app oficial. Escolha o prestador e reveja antes de submeter.",
        confirmation:
          "O pedido é enviado ao prestador, com cópia por email para si. A data e a hora são confirmadas posteriormente pelo prestador; enviar o pedido não reserva uma vaga.",
        alternative:
          "Confirme que o prestador realiza o exame na morada escolhida. Para alterar ou cancelar, contacte o prestador: o SNS 24 não disponibiliza essa operação para estes pedidos."
      },
      en: %{
        title: "Request tests near you",
        requirements:
          "You need an active electronic referral with eligible tests. Only providers contracted for the selected tests are shown.",
        portal:
          "In the SNS 24 portal, open Receitas e exames → Exames and select the referral. Choose Pedir agendamento de exames, the tests and district/municipality. Select a provider, check its address and review before submitting.",
        app:
          "In the SNS 24 app, open Receitas e exames → Exames, select the referral and Pedir agendamento de exames. Enter a district/municipality or use Ver entidades perto de mim, allowing location in the official app. Select a provider and review before submitting.",
        confirmation:
          "The request is sent to the provider, with an email copy to you. The provider confirms the date and time later; sending the request does not reserve a slot.",
        alternative:
          "Check that the provider offers the test at the selected address. Contact the provider to change or cancel: SNS 24 does not offer that operation for these requests."
      }
    },
    %{
      id: "medication",
      source: "https://www.sns24.gov.pt/pt/servico/renovar-medicacao-habitual/",
      pt: %{
        title: "Pedir renovação de medicação habitual",
        requirements:
          "Precisa de inscrição num centro de saúde e de medicação habitual ativa. Pode utilizar o serviço mesmo sem médico de família atribuído.",
        portal:
          "No Portal SNS 24, abra Receitas e exames → Medicação habitual → Medicamentos → Renovar medicamentos. Selecione os medicamentos ativos que pretende renovar, reveja e submeta o pedido.",
        app:
          "Na App SNS 24, abra Receitas e exames → Medicação habitual → Ver tudo → Renovar medicamentos. Selecione os medicamentos, reveja e submeta o pedido.",
        confirmation:
          "Acompanhe em Pedidos de renovação. A renovação depende de aprovação da unidade; só depois os medicamentos renovados ficam disponíveis em Receitas.",
        alternative:
          "Se a medicação não aparecer, contacte o médico ou a unidade para verificar o registo. O eCidadão não recomenda medicamentos nem altera o tratamento."
      },
      en: %{
        title: "Request a repeat prescription",
        requirements:
          "You must be registered at a health centre and have active regular medication recorded. You can use this service even without an assigned family doctor.",
        portal:
          "In the SNS 24 portal, open Receitas e exames → Medicação habitual → Medicamentos → Renovar medicamentos. Select the active medicines you want renewed, review and submit the request.",
        app:
          "In the SNS 24 app, open Receitas e exames → Medicação habitual → Ver tudo → Renovar medicamentos. Select the medicines, review and submit the request.",
        confirmation:
          "Track it in Pedidos de renovação. Approval by the health centre is required; renewed prescriptions appear in Receitas only afterwards.",
        alternative:
          "If medication is missing, contact your doctor or health centre to check the record. eCidadão does not recommend medicines or change treatment."
      }
    },
    %{
      id: "referrals",
      source: "https://www.sns24.gov.pt/pt/servico/referenciacoes/",
      pt: %{
        title: "Acompanhar uma referenciação hospitalar",
        requirements:
          "É necessário existir uma referenciação emitida por um profissional de saúde para outra instituição do SNS.",
        portal:
          "Inicie sessão no Portal SNS 24 e abra Consultas e referenciações → Referenciações. Consulte os registos e o estado do pedido.",
        app:
          "Na App SNS 24, abra Consultas e referenciações → Referenciações e consulte os detalhes do pedido.",
        confirmation:
          "Uma referenciação é um pedido de encaminhamento. Não equivale a consulta marcada; confirme a data e a hora com a instituição e nos canais oficiais.",
        alternative:
          "Se o pedido não aparecer ou precisar de esclarecimento sobre o estado, contacte a unidade que o referenciou ou a instituição de destino. Este serviço não cria referenciações."
      },
      en: %{
        title: "Track a hospital referral",
        requirements:
          "A health professional must have issued a referral to another SNS institution.",
        portal:
          "Sign in to the SNS 24 portal and open Consultas e referenciações → Referenciações. View the records and request status.",
        app:
          "In the SNS 24 app, open Consultas e referenciações → Referenciações and view the request details.",
        confirmation:
          "A referral is a request for care elsewhere. It is not a confirmed appointment; check the date and time with the institution and official channels.",
        alternative:
          "If a request is missing or its status is unclear, contact the referring unit or destination institution. This service does not create referrals."
      }
    }
  ]

  def services, do: Enum.map(@routes, & &1.id)

  def all(locale \\ "pt") when locale in ["pt", "en"] do
    key = if locale == "en", do: :en, else: :pt
    Enum.map(@routes, &Map.merge(Map.take(&1, [:id, :source]), Map.fetch!(&1, key)))
  end

  def guide(args) when is_map(args) do
    service = Map.get(args, "service")
    locale = Map.get(args, "language", "pt")
    channel = Map.get(args, "channel", "both")

    if service in services() and locale in ["pt", "en"] and
         channel in ["portal", "app", "both"] and
         Enum.all?(Map.keys(args), &(&1 in ["service", "language", "channel"])) do
      route = Enum.find(all(locale), &(&1.id == service))

      navigation =
        case channel do
          "portal" -> route.portal
          "app" -> route.app
          "both" -> route.portal <> "\n\n" <> route.app
        end

      disclaimer =
        if locale == "en",
          do:
            "Guidance only. eCidadão has not accessed your account, checked availability or submitted a request. Sign in only on official SNS 24 channels. Portuguese menu labels are retained to help you find them.",
          else:
            "Apenas orientação. O eCidadão não acedeu à conta, consultou vagas ou enviou pedidos. Inicie sessão apenas nos canais oficiais do SNS 24."

      {:ok,
       %{
         status: "guidance_only",
         service: service,
         language: locale,
         channel: channel,
         title: route.title,
         requirements: route.requirements,
         navigation: navigation,
         confirmation: route.confirmation,
         alternative: route.alternative,
         source: route.source,
         verified_on: "2026-11-27",
         submitted: false,
         steps:
           Enum.join(
             [
               disclaimer,
               route.title,
               route.requirements,
               navigation,
               route.confirmation,
               route.alternative,
               route.source
             ],
             "\n\n"
           )
       }}
    else
      {:error,
       %{
         input:
           "Use service válido, language pt/en e channel portal/app/both. Não envie dados pessoais."
       }}
    end
  end

  def guide(_), do: {:error, %{input: "Envie apenas service, language e channel."}}
end
