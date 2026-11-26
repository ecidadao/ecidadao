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
    fields = Map.new(@limits, fn {key, _} -> {key, clean(input[key])} end)
    type = clean(input["type"])

    errors =
      for {key, max} <- @limits,
          (key in @required and fields[key] == "") or String.length(fields[key]) > max do
        %{
          field: key,
          message:
            if(fields[key] == "", do: "Campo obrigatório.", else: "Máximo de #{max} caracteres.")
        }
      end

    errors =
      if Map.has_key?(@types, type),
        do: errors,
        else: [%{field: "type", message: "Escolha reclamação, elogio ou sugestão."} | errors]

    errors =
      if fields["incident_date"] != "" and
           match?({:error, _}, Date.from_iso8601(fields["incident_date"])),
         do: [%{field: "incident_date", message: "Use a data AAAA-MM-DD."} | errors],
         else: errors

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
          optional("Resultado ou melhoria pretendida", fields["requested_resolution"]),
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
           "Abra o gov.pt, confirme a entidade e o serviço, autentique-se e reveja o texto antes de enviar. Guarde o comprovativo oficial."
       }}
    else
      {:error, errors}
    end
  end

  def prepare(_), do: {:error, [%{field: "input", message: "Envie os dados do pedido."}]}
  defp clean(value) when is_binary(value), do: String.trim(value)
  defp clean(_), do: ""
  defp optional(_, ""), do: nil
  defp optional(label, value), do: "#{label}: #{value}"
end
