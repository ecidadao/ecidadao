defmodule Ecidadao.MunicipalDirectory do
  @moduledoc """
  Offline municipal catalogue, not an executable municipal API.

  `search/1` accepts only string keys: municipality (all, gondomar, maia,
  ponte_de_lima), query (at most 160 characters), limit (1..30), language
  (pt, en). Defaults are all, empty query, 12, pt. Responses use atom keys;
  catalogue items and source maps use string keys. Queries are never returned
  or persisted. `verified_on` dates the source snapshot, not live availability.
  Authentication `required` reflects Gondomar's own menu flag only.
  """
  @path Path.expand("../../priv/municipal_services.json", __DIR__)
  @external_resource @path
  @catalogue @path |> File.read!() |> Jason.decode!()
  @municipalities ~w(all gondomar maia ponte_de_lima)
  @keys ~w(municipality query limit language)
  @stopwords ~w(a o as os de da do das dos e em no na nos nas um uma para por com ao aos quero queria preciso pedir pedido pedidos como posso obter encontrar the a an of for to in on i want need how can get request please me my meu minha)
  @aliases [
    {~w(estacionamento), "parking park permit resident residente cartao"},
    {~w(habitacao renda rendas),
     "housing rent rental support habitacao renda apoio arrendamento"},
    {~w(tarifario tarifarios),
     "water tariff tariffs agua tarifario social desconto discount bill"},
    {~w(monos monstros volumosos frigorifico),
     "bulky waste collection collect furniture sofa velho moveis recolha recolher monos monstros volumosos lixo eletrodomesticos"},
    {~w(certidao certidoes certificado),
     "certificate certificates certidao certidoes certificado"},
    {~w(escolar escolares), "school escola escolar escolares"},
    {~w(transporte transportes), "transport transporte transportes bus autocarro"},
    {~w(atendimento audiencia), "appointment booking atendimento agendar marcacao"},
    {~w(renovacao), "renew renewal renovar renovacao"}
  ]

  @doc "Search the static catalogue without network access or personal data."
  @spec search(term()) :: {:ok, map()} | {:error, map()}
  def search(args) when is_map(args) do
    municipality = Map.get(args, "municipality", "all")
    query = Map.get(args, "query", "")
    limit = Map.get(args, "limit", 12)
    language = Map.get(args, "language", "pt")

    if Enum.all?(Map.keys(args), &(&1 in @keys)) and municipality in @municipalities and
         is_binary(query) and String.valid?(query) and String.length(query) <= 160 and
         is_integer(limit) and limit in 1..30 and language in ["pt", "en"] do
      normalized = normalize(query)
      tokens = normalized |> String.split() |> Enum.reject(&(&1 in @stopwords))

      matches =
        @catalogue["services"]
        |> Enum.filter(&(municipality == "all" or &1["municipality"] == municipality))
        |> Enum.map(&{&1, score(&1, normalized, tokens)})
        |> Enum.reject(fn {_, score} -> score < 0 end)
        |> Enum.sort_by(fn {item, score} ->
          {-score, item["municipality"], normalize(item["title"]), item["id"]}
        end)

      {:ok,
       %{
         municipality: municipality,
         total: length(matches),
         results: matches |> Enum.take(limit) |> Enum.map(&elem(&1, 0)),
         limit: limit,
         language: language,
         verified_on: @catalogue["verified_on"],
         sources: sources(municipality),
         status: "catalogue_only",
         submitted: false,
         availability_checked: false,
         notice: notice(language),
         steps: steps(language)
       }}
    else
      invalid()
    end
  end

  def search(_), do: invalid()

  defp invalid do
    {:error,
     %{
       error: "invalid_arguments",
       status: "catalogue_only",
       submitted: false,
       message: "Use municipality, query (max 160 characters), limit (1..30), language (pt|en)."
     }}
  end

  defp sources("all"), do: @catalogue["sources"]
  defp sources(municipality), do: Map.take(@catalogue["sources"], [municipality])

  defp normalize(text) do
    text
    |> String.normalize(:nfd)
    |> String.downcase()
    |> String.replace(~r/\p{Mn}/u, "")
    |> String.replace(~r/[^\p{L}\p{N}]+/u, " ")
    |> String.trim()
  end

  defp score(item, query, tokens) do
    title = normalize(item["title"])
    words = String.split(title)
    category = normalize(Map.get(item, "category", ""))

    aliases =
      @aliases
      |> Enum.filter(fn {triggers, _} -> Enum.any?(triggers, &(&1 in words)) end)
      |> Enum.map_join(" ", &elem(&1, 1))

    searchable = String.split(title <> " " <> category <> " " <> aliases)

    cond do
      query == "" ->
        0

      title == query ->
        1000

      tokens == [] ->
        -1

      Enum.all?(tokens, &(&1 in searchable)) ->
        10 * Enum.count(tokens, &(&1 in words)) +
          if(String.contains?(title, query), do: 100, else: 0)

      true ->
        -1
    end
  end

  defp notice("en"),
    do:
      "Static catalogue of official links; availability is not checked. Official service titles remain in Portuguese. Requirements, authentication and opening periods must be confirmed on the official portal. Nothing has been submitted."

  defp notice("pt"),
    do:
      "Catálogo estático de ligações oficiais; a disponibilidade não é verificada. Confirme requisitos, autenticação e períodos de abertura no portal oficial. Não foi submetido nenhum pedido."

  defp steps("en"),
    do: [
      "Choose the service and open its official link.",
      "Confirm the current instructions on the municipal portal.",
      "Complete any request through the official channel."
    ]

  defp steps("pt"),
    do: [
      "Escolha o serviço e abra a ligação oficial.",
      "Confirme as instruções atuais no portal municipal.",
      "Faça o pedido através do canal oficial."
    ]
end
