defmodule Ecidadao.PublicFeedback do
  @moduledoc "Prepares Livro Amarelo feedback locally, without contacting the official portal."

  @types %{
    "complaint" => {"Reclamação", "fazer-reclamacao-de-um-servico-publico"},
    "compliment" => {"Elogio", "fazer-elogio-a-um-servico-publico"},
    "suggestion" => {"Sugestão", "fazer-sugestao-a-um-servico-publico"}
  }
  @limits %{
    "organisation" => 200,
    "location" => 200,
    "incident_date" => 10,
    "subject" => 200,
    "description" => 5000,
    "requested_resolution" => 1500
  }
  @required ~w(organisation subject description)

  def types, do: ~w(complaint compliment suggestion)

  def prepare(input) when is_map(input) do
    fields = Map.new(@limits, fn {key, _} -> {key, clean(Map.get(input, key))} end)
    type = clean(Map.get(input, "type"))

    errors =
      Enum.flat_map(@limits, fn {key, max} ->
        value = Map.get(input, key)

        cond do
          not is_nil(value) and not is_binary(value) ->
            [%{field: key, message: "Use texto neste campo."}]

          is_binary(value) and not String.valid?(value) ->
            [%{field: key, message: "Use texto UTF-8 válido."}]

          key in @required and fields[key] == "" ->
            [%{field: key, message: "Campo obrigatório."}]

          String.length(fields[key]) > max ->
            [%{field: key, message: "Máximo de #{max} caracteres."}]

          key == "incident_date" and fields[key] != "" and
              (not Regex.match?(~r/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/, fields[key]) or
                 not match?({:ok, _}, Date.from_iso8601(fields[key]))) ->
            [%{field: key, message: "Use uma data válida AAAA-MM-DD."}]

          true ->
            []
        end
      end)

    errors =
      if Map.has_key?(@types, type),
        do: errors,
        else: [%{field: "type", message: "Escolha reclamação, elogio ou sugestão."} | errors]

    if errors == [] do
      {label, path} = Map.fetch!(@types, type)
      portal = "https://www.gov.pt/servicos/" <> path

      draft =
        [
          "RASCUNHO LIVRO AMARELO — NÃO SUBMETIDO",
          "Tipo: #{label}",
          "Entidade pública: #{fields["organisation"]}",
          optional("Local de atendimento", fields["location"]),
          optional("Data", fields["incident_date"]),
          "Assunto: #{fields["subject"]}",
          "Descrição:\n#{fields["description"]}",
          optional(resolution_label(type), fields["requested_resolution"]),
          "Reveja e conclua no portal oficial: #{portal}",
          "Este rascunho não foi enviado. Guarde o comprovativo emitido pelo portal após a submissão."
        ]
        |> Enum.reject(&is_nil/1)
        |> Enum.join("\n\n")

      {:ok,
       %{
         status: "rascunho_nao_submetido",
         type: type,
         fields: fields,
         draft: draft,
         official_portal: portal,
         authentication_required: true,
         next_step:
           "Abra o gov.pt, confirme a entidade e o serviço, autentique-se e reveja o texto antes de enviar. Preencha a identificação apenas no portal oficial e guarde o comprovativo que este emitir."
       }}
    else
      {:error, errors}
    end
  end

  def prepare(_), do: {:error, [%{field: "input", message: "Envie os dados do pedido."}]}
  defp resolution_label("complaint"), do: "Resultado pretendido"
  defp resolution_label("compliment"), do: "Reconhecimento pretendido"
  defp resolution_label("suggestion"), do: "Melhoria pretendida"

  defp clean(value) when is_binary(value) do
    if String.valid?(value), do: String.trim(value), else: ""
  end

  defp clean(_), do: ""
  defp optional(_, ""), do: nil
  defp optional(label, value), do: "#{label}: #{value}"
end
