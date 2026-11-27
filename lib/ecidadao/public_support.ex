defmodule Ecidadao.PublicSupport do
  @moduledoc """
  Dated public support snapshots, without account access or personal-data processing.

  `all/1` returns localized maps; `guide/1` accepts only string keys `service` and
  optional `language` (`pt` or `en`). `all/2` and `guide/2` accept an internal
  Date for deterministic deadline evaluation, never a public input field.
  Deadlines are inclusive calendar dates, not a claim of live availability.
  """
  @verified_on "2026-11-27"
  @catalogue Path.expand("../../priv/public_support.json", __DIR__)
  @external_resource @catalogue
  @routes @catalogue |> File.read!() |> Jason.decode!()

  def services, do: Enum.map(@routes, & &1["id"])

  def all(language \\ "pt"), do: all(language, Date.utc_today())

  @doc false
  def all(language, %Date{} = today) when language in ["pt", "en"] do
    Enum.map(@routes, &localize(&1, language, today))
  end

  def guide(args), do: guide(args, Date.utc_today())

  @doc false
  def guide(args, %Date{} = today) when is_map(args) do
    language = Map.get(args, "language", "pt")

    if args["service"] in services() and language in ["pt", "en"] and
         Enum.all?(Map.keys(args), &(&1 in ["service", "language"])) do
      {:ok, Enum.find(all(language, today), &(&1.id == args["service"]))}
    else
      invalid(language)
    end
  end

  def guide(_, %Date{}), do: invalid("pt")

  defp invalid("en"),
    do:
      {:error,
       %{input: "Use a listed service and language pt/en only. Do not send personal data."}}

  defp invalid(_),
    do:
      {:error, %{input: "Use apenas service válido e language pt/en. Não envie dados pessoais."}}

  defp localize(route, language, today) do
    copy = route[language]

    phases =
      Enum.map(route["phases"], fn phase ->
        state = phase_state(phase, today)

        %{
          action: phase["action"],
          status: state,
          published_deadline: phase["published_deadline"],
          evidence_on: phase["evidence_on"] || @verified_on,
          as_of: Date.to_iso8601(today),
          source: phase["source"] || route["source"],
          guidance: phase[language] <> " " <> phase_message(state, language)
        }
      end)

    disclaimer =
      if language == "en" do
        "Guidance only, based on dated sources; no live award or budget search. No personal data is accepted or collected. Eligibility, approval and payment are not guaranteed. Check current rules and availability on the official portal; authenticate and provide documents only there."
      else
        "Apenas orientação com fontes datadas; sem pesquisa de apoios ou verbas em tempo real. Não são aceites nem recolhidos dados pessoais. Não há garantia de elegibilidade, aprovação ou pagamento. Confirme regras e disponibilidade no portal oficial; autentique-se e entregue documentos apenas aí."
      end

    result = %{
      id: route["id"],
      service: route["id"],
      language: language,
      title: copy["title"],
      audience: copy["audience"],
      purpose: copy["purpose"],
      requirements: copy["requirements"],
      checklist: copy["checklist"],
      navigation: copy["navigation"],
      confirmation: disclaimer,
      source: route["source"],
      sources: route["sources"],
      application_url: route["application_url"],
      application_phases: phases,
      status: "guidance_only",
      submitted: false,
      verified_on: @verified_on,
      as_of: Date.to_iso8601(today),
      remaining_budget: nil,
      example: copy["example"]
    }

    Map.put(
      result,
      :steps,
      Enum.join(
        [disclaimer, result.title, result.audience, result.purpose, result.requirements] ++
          result.checklist ++
          Enum.map(phases, & &1.guidance) ++
          [result.navigation] ++ result.sources,
        "\n\n"
      )
    )
  end

  defp phase_state(phase, today) do
    cond do
      Date.compare(today, Date.from_iso8601!(phase["evidence_on"] || @verified_on)) == :lt ->
        "unknown_before_evidence"

      phase["status"] == "within_published_deadline" and phase["published_deadline"] != nil and
          Date.compare(today, Date.from_iso8601!(phase["published_deadline"])) == :gt ->
        "published_deadline_passed"

      true ->
        phase["status"]
    end
  end

  defp phase_message("published_deadline_passed", "en"),
    do: "The published deadline has passed; no extension or new round has been verified."

  defp phase_message("published_deadline_passed", "pt"),
    do: "O prazo publicado terminou; não foi verificada prorrogação ou nova fase."

  defp phase_message("within_published_deadline", "en"),
    do: "Within the published deadline; confirm current availability on the official portal."

  defp phase_message("within_published_deadline", "pt"),
    do: "Dentro do prazo publicado; confirme a disponibilidade atual no portal oficial."

  defp phase_message("unknown_before_evidence", "en"),
    do: "This snapshot cannot establish the status before its evidence date."

  defp phase_message("unknown_before_evidence", "pt"),
    do: "Este registo não permite determinar o estado anterior à data da evidência."

  defp phase_message(_, "en"), do: "Dated observation; check the official source for updates."
  defp phase_message(_, "pt"), do: "Observação datada; confirme atualizações na fonte oficial."
end
