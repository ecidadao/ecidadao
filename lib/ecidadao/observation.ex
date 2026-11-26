defmodule Ecidadao.Observation do
  @moduledoc "Prepares a first report preview from facts the user or ChatGPT observed in a photo."

  @contexts ~w(street public_service business unknown)

  def preview(input, metadata \\ %{})

  def preview(input, metadata) when is_map(input) do
    observations = clean(Map.get(input, "observations"))
    context = clean(Map.get(input, "context_hint"))
    context = if context in @contexts, do: context, else: "unknown"
    organization = clean(Map.get(input, "organization_name"))

    errors =
      []
      |> require_observations(observations)
      |> check_length("observations", observations, 2000)
      |> check_length("organization_name", organization, 160)

    if errors == [] do
      location_hint = coarse_location(metadata)
      {channel, next_question} = route(context, organization)

      {:ok,
       %{
         status: "previsualizacao_nao_submetida",
         observations: observations,
         context: context,
         suggested_channel: channel,
         organization_name: organization,
         location_hint: location_hint,
         location_confirmed: false,
         next_question: next_question,
         draft:
           "O que se observa: #{observations}\nLocal exato: por confirmar.\nEntidade responsável: por confirmar.\nEste reporte ainda não foi enviado."
       }}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  def preview(_, _),
    do: {:error, [%{field: "input", message: "Envie os factos observados na fotografia."}]}

  defp require_observations(errors, ""),
    do: [%{field: "observations", message: "Descreva o que é visível na fotografia."} | errors]

  defp require_observations(errors, _), do: errors

  defp check_length(errors, field, value, max) do
    if String.length(value) > max do
      [%{field: field, message: "Máximo de #{max} caracteres."} | errors]
    else
      errors
    end
  end

  defp clean(value) when is_binary(value), do: String.trim(value)
  defp clean(_), do: ""

  defp coarse_location(metadata) when is_map(metadata) do
    location = Map.get(metadata, "openai/userLocation", %{})

    if is_map(location) do
      [Map.get(location, "city"), Map.get(location, "region"), Map.get(location, "country")]
      |> Enum.filter(&(is_binary(&1) and &1 != ""))
      |> Enum.uniq()
      |> Enum.join(", ")
      |> case do
        "" -> nil
        hint -> hint
      end
    else
      nil
    end
  end

  defp coarse_location(_), do: nil

  defp route("street", _),
    do: {"A Minha Rua", "Confirma o local exato da ocorrência?"}

  defp route("business", ""),
    do: {"Livro de Reclamações Eletrónico", "Qual é a empresa ou entidade reclamada?"}

  defp route("business", _),
    do:
      {"Livro de Reclamações Eletrónico",
       "Confirma a entidade e o que pretendes que seja resolvido?"}

  defp route("public_service", ""),
    do: {"por determinar", "Em que serviço público aconteceu e em que local exato?"}

  defp route("public_service", _),
    do: {"por determinar", "Confirma o serviço, o local exato e o resultado pretendido?"}

  defp route(_, _),
    do:
      {"por determinar",
       "O problema é na rua, num serviço público ou numa compra/serviço comercial?"}
end
