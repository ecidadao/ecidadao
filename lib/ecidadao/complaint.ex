defmodule Ecidadao.Complaint do
  @moduledoc "Stateless preparation of a consumer complaint for the official portal."

  @fields ~w(consumer_name consumer_email business_name reference incident_date description requested_resolution)
  @required ~w(business_name description requested_resolution)
  @limits %{
    "consumer_name" => 120,
    "consumer_email" => 254,
    "business_name" => 160,
    "reference" => 100,
    "incident_date" => 10,
    "description" => 5000,
    "requested_resolution" => 1500
  }

  def prepare(input) when is_map(input) do
    data = Map.new(@fields, fn key -> {key, clean(Map.get(input, key))} end)
    errors = validate(data)

    if errors == [] do
      {:ok,
       %{
         fields: data,
         draft: format(data),
         status: "rascunho_nao_submetido",
         official_portal: "https://www.livroreclamacoes.pt/Inicio/",
         next_step:
           "Reveja os dados e apresente a reclamação no Livro de Reclamações Eletrónico. Guarde o comprovativo emitido pelo portal oficial."
       }}
    else
      {:error, errors}
    end
  end

  def prepare(_),
    do: {:error, [%{field: "input", message: "Envie um objeto com os dados da reclamação."}]}

  defp clean(value) when is_binary(value), do: String.trim(value)
  defp clean(_), do: ""

  defp validate(data) do
    required =
      for field <- @required, data[field] == "" do
        %{field: field, message: "Campo obrigatório."}
      end

    lengths =
      for {field, max} <- @limits, String.length(data[field]) > max do
        %{field: field, message: "Máximo de #{max} caracteres."}
      end

    email =
      if data["consumer_email"] != "" and
           not Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/u, data["consumer_email"]) do
        [%{field: "consumer_email", message: "Endereço de email inválido."}]
      else
        []
      end

    date =
      if data["incident_date"] != "" and
           match?({:error, _}, Date.from_iso8601(data["incident_date"])) do
        [%{field: "incident_date", message: "Use a data AAAA-MM-DD."}]
      else
        []
      end

    required ++ lengths ++ email ++ date
  end

  defp format(data) do
    [
      "RASCUNHO DE RECLAMAÇÃO — AINDA NÃO SUBMETIDO",
      "Entidade reclamada: #{data["business_name"]}",
      optional("Reclamante", data["consumer_name"]),
      optional("Email", data["consumer_email"]),
      optional("Referência", data["reference"]),
      optional("Data da ocorrência", data["incident_date"]),
      "\nDescrição dos factos:\n#{data["description"]}",
      "\nResolução pretendida:\n#{data["requested_resolution"]}",
      "\nPrepare este texto no portal oficial: https://www.livroreclamacoes.pt/Inicio/",
      "A preparação deste rascunho não equivale à apresentação de uma reclamação."
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  defp optional(_label, ""), do: nil
  defp optional(label, value), do: "#{label}: #{value}"
end
