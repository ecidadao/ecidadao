defmodule Ecidadao.Siga do
  @moduledoc "Read-only comparison of the public SIGA queue view. Does not issue tickets."

  @queue_url "https://siga.marcacaodeatendimento.pt/Senhas/TemposEspera"
  @appointment_url "https://siga.marcacaodeatendimento.pt/Marcacao/MarcacaoInicio"
  @base "https://siga.marcacaodeatendimento.pt"

  @districts [
    {"Aveiro", 1},
    {"Beja", 2},
    {"Braga", 3},
    {"Bragança", 4},
    {"Castelo Branco", 5},
    {"Coimbra", 6},
    {"Évora", 7},
    {"Faro", 8},
    {"Guarda", 9},
    {"Leiria", 10},
    {"Lisboa", 11},
    {"Portalegre", 12},
    {"Porto", 13},
    {"Santarém", 14},
    {"Setúbal", 15},
    {"Viana do Castelo", 16},
    {"Vila Real", 17},
    {"Viseu", 18},
    {"Madeira", 31},
    {"Porto Santo", 32},
    {"Santa Maria", 41},
    {"São Miguel", 42},
    {"Terceira", 43},
    {"Graciosa", 44},
    {"São Jorge", 45},
    {"Pico", 46},
    {"Faial", 47},
    {"Flores", 48},
    {"Corvo", 49}
  ]

  def queue_url, do: @queue_url
  def appointment_url, do: @appointment_url
  def districts, do: @districts

  def guide(%{"purpose" => purpose}) when purpose in ["appointment", "queues", "ticket"] do
    {url, steps} =
      case purpose do
        "appointment" ->
          {@appointment_url,
           "Pesquise o assunto ou escolha a entidade, selecione a modalidade, local e horário, e confirme a marcação no SIGA. Algumas entidades pedem autenticação."}

        "queues" ->
          {@queue_url,
           "Escolha distrito, entidade e tipo de senha, pesquise e confirme o estado atualizado dos balcões no SIGA."}

        "ticket" ->
          {@queue_url,
           "Escolha distrito, entidade e senha. Se o balcão permitir senha web, indique o email e confirme o código recebido no SIGA."}
      end

    {:ok,
     %{
       status: "orientacao_sem_marcacao",
       purpose: purpose,
       official_portal: url,
       steps: steps,
       warning: "O eCidadão não emite senhas nem conclui marcações. A disponibilidade pode mudar."
     }}
  end

  def guide(_),
    do: {:error, [%{field: "purpose", message: "Escolha appointment, queues ou ticket."}]}

  def compare(input, fetcher \\ &Ecidadao.SigaCache.fetch/2)

  def compare(input, fetcher) when is_map(input) do
    district = district_id(Map.get(input, "district"))
    entity = clean(Map.get(input, "entity"))
    ticket = clean(Map.get(input, "ticket_type"))
    latitude = number(Map.get(input, "latitude"))
    longitude = number(Map.get(input, "longitude"))
    radius = number(Map.get(input, "radius_km", 40))

    errors =
      []
      |> invalid(district == nil, "district", "Escolha um distrito válido.")
      |> invalid(
        entity == "" or String.length(entity) > 120,
        "entity",
        "Indique a entidade (máximo 120 caracteres)."
      )
      |> invalid(
        ticket == "" or String.length(ticket) > 120,
        "ticket_type",
        "Indique o tipo de senha (máximo 120 caracteres)."
      )
      |> invalid(
        latitude == nil or latitude < -90 or latitude > 90,
        "latitude",
        "Indique latitude válida."
      )
      |> invalid(
        longitude == nil or longitude < -180 or longitude > 180,
        "longitude",
        "Indique longitude válida."
      )
      |> invalid(
        radius == nil or radius <= 0 or radius > 100,
        "radius_km",
        "Escolha um raio de 1 a 100 km."
      )

    if errors != [] do
      {:error, errors}
    else
      compare_valid(district, entity, ticket, latitude, longitude, radius, fetcher)
    end
  end

  def compare(_, _),
    do: {:error, [%{field: "input", message: "Envie os parâmetros da pesquisa."}]}

  defp compare_valid(district, entity, ticket, latitude, longitude, radius, fetcher) do
    with {:ok, entities} <-
           fetcher.("/Senhas/GetEntidadesNoDistrito", %{"IdDistrito" => district}),
         {:ok, chosen_entity} <- choose(entities, entity, "entity"),
         params = %{
           "IdDistrito" => district,
           "IdEntidade" => chosen_entity["id"],
           "IdInstituicaoSelecionada" => chosen_entity["idInstituicao"],
           "Latitude" => 0,
           "Longitude" => 0,
           "EstadoLocalizacao" => 0
         },
         {:ok, ticket_types} <- fetcher.("/Senhas/GetSenhas", params),
         {:ok, chosen_ticket} <- choose(ticket_types, ticket, "ticket_type"),
         {:ok, locations} <-
           fetcher.("/Senhas/GetLocais", Map.put(params, "IdSenha", chosen_ticket["id"])) do
      locations =
        locations
        |> Enum.flat_map(&location(&1, latitude, longitude, radius))
        |> Enum.sort_by(fn place ->
          {if(place.open, do: 0, else: 1), place.wait_minutes || 1_000_000, place.distance_km}
        end)

      fastest = Enum.find(locations, &(&1.open and is_integer(&1.wait_minutes)))

      {:ok,
       %{
         status: "consulta_publica_nao_reserva",
         district: district_name(district),
         entity: chosen_entity["nome"],
         ticket_type: chosen_ticket["nome"],
         radius_km: radius,
         observed_at: DateTime.utc_now() |> DateTime.to_iso8601(),
         locations: Enum.take(locations, 20),
         total_in_radius: length(locations),
         fastest_reported_queue: if(fastest, do: fastest.name, else: nil),
         official_queue_url: @queue_url,
         official_appointment_url: @appointment_url,
         note:
           "Comparação pelo tempo de espera publicado, sem tempo de deslocação. A pesquisa parte do distrito escolhido; pode não cobrir todos os balcões de distritos vizinhos. Estados e tempos podem mudar. A senha e a marcação são concluídas no SIGA."
       }}
    else
      {:error, errors} when is_list(errors) ->
        {:error, errors}

      {:error, reason} ->
        {:error, [%{field: "source", message: "Consulta SIGA indisponível: #{inspect(reason)}"}]}
    end
  end

  defp choose(items, query, field) when is_list(items) do
    candidates = Enum.filter(items, &is_map/1)
    exact = Enum.filter(candidates, &(normalize(&1["nome"]) == normalize(query)))

    matches =
      if exact == [],
        do:
          Enum.filter(
            candidates,
            &String.contains?(normalize(&1["nome"] || ""), normalize(query))
          ),
        else: exact

    case matches do
      [item] ->
        {:ok, item}

      [] ->
        {:error,
         [
           %{
             field: field,
             message: "Não encontrado no distrito. Confirme no portal oficial.",
             options: Enum.map(candidates, & &1["nome"]) |> Enum.take(30)
           }
         ]}

      _ ->
        {:error,
         [
           %{
             field: field,
             message: "Escolha um nome mais específico.",
             options: Enum.map(matches, & &1["nome"]) |> Enum.take(20)
           }
         ]}
    end
  end

  defp choose(_, _, field),
    do: {:error, [%{field: field, message: "Resposta inesperada do SIGA."}]}

  defp location(%{"servico" => service} = item, lat, lon, radius) when is_map(service) do
    with %{"latitude" => place_lat, "longitude" => place_lon} <- item,
         true <- is_number(place_lat) and is_number(place_lon),
         distance <- haversine(lat, lon, place_lat, place_lon),
         true <- distance <= radius do
      wait = service["tempoRealEspera"]

      [
        %{
          name: item["nome"],
          address: item["morada"],
          district: district_name(item["distritoId"]),
          distance_km: Float.round(distance, 1),
          open: service["estado"] == "ABERTO",
          state: service["estado"],
          wait_minutes: if(is_number(wait) and wait >= 0, do: ceil(wait / 60), else: nil),
          people_waiting: service["utentesEmEspera"],
          web_ticket_available: service["senhaWeb"] == true
        }
      ]
    else
      _ -> []
    end
  end

  defp location(_, _, _, _), do: []

  defp haversine(lat1, lon1, lat2, lon2) do
    rad = :math.pi() / 180
    dlat = (lat2 - lat1) * rad
    dlon = (lon2 - lon1) * rad

    a =
      :math.sin(dlat / 2) ** 2 +
        :math.cos(lat1 * rad) * :math.cos(lat2 * rad) * :math.sin(dlon / 2) ** 2

    6371 * 2 * :math.asin(min(1, :math.sqrt(a)))
  end

  def fetch_json(path, params) do
    headers = [
      {~c"user-agent", ~c"eCidadao/0.3 (+https://ecidadao.pt)"},
      {~c"x-requested-with", ~c"XMLHttpRequest"}
    ]

    request =
      {String.to_charlist(@base <> path), headers, ~c"application/x-www-form-urlencoded",
       URI.encode_query(params) |> String.to_charlist()}

    options = [
      timeout: 8_000,
      connect_timeout: 4_000,
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        customize_hostname_check: [match_fun: :public_key.pkix_verify_hostname_match_fun(:https)]
      ]
    ]

    case :httpc.request(:post, request, options, body_format: :binary) do
      {:ok, {{_, 200, _}, _, body}} when byte_size(body) <= 1_000_000 ->
        case Jason.decode(body) do
          {:ok, value} when is_list(value) -> {:ok, value}
          _ -> {:error, :unexpected_response}
        end

      {:ok, {{_, status, _}, _, _}} ->
        {:error, {:http_status, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp district_id(value) when is_integer(value),
    do: if(Enum.any?(@districts, &(&1 |> elem(1) == value)), do: value, else: nil)

  defp district_id(value) when is_binary(value) do
    case Integer.parse(value) do
      {id, ""} ->
        district_id(id)

      _ ->
        Enum.find_value(@districts, fn {name, id} ->
          if normalize(name) == normalize(value), do: id
        end)
    end
  end

  defp district_id(_), do: nil

  defp district_name(id),
    do: @districts |> Enum.find_value(fn {name, value} -> if value == id, do: name end)

  defp number(value) when is_number(value), do: value

  defp number(value) when is_binary(value) do
    case Float.parse(value) do
      {number, ""} -> number
      _ -> nil
    end
  end

  defp number(_), do: nil
  defp clean(value) when is_binary(value), do: String.trim(value)
  defp clean(_), do: ""

  defp normalize(value) when is_binary(value),
    do:
      value
      |> String.trim()
      |> String.downcase()
      |> String.normalize(:nfd)
      |> String.replace(~r/\p{Mn}/u, "")

  defp normalize(_), do: ""
  defp invalid(errors, true, field, message), do: errors ++ [%{field: field, message: message}]
  defp invalid(errors, false, _, _), do: errors
end
