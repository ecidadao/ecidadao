defmodule Ecidadao.MunicipalAppointments do
  @moduledoc """
  Read-only Ponte de Lima public, in-person appointment availability.

  `lookup/2` accepts strict string-keyed parameters and an optional function
  `(endpoint, query_map) -> {:ok, decoded_json} | {:error, reason}`. Injected
  fetchers bypass the production cache. Production requires MunicipalAppointmentsCache
  in the supervision tree. Dates are restricted to today through 366 days ahead (UTC).
  The municipality's frontend endpoints are not a supported external API contract.
  """
  @base "https://www.cm-pontedelima.pt/api/v1/appointments/"
  @portal "https://www.cm-pontedelima.pt/pages/1606"
  @areas "get_avaible_customer_areas"
  @dates "get_available_dates"
  @slots "get_empty"
  @limit 1_000_000

  def lookup(args, fetcher \\ nil) do
    language = if is_map(args) and args["language"] == "en", do: "en", else: "pt"

    with {:ok, input} <- validate(args) do
      if is_nil(fetcher) do
        Ecidadao.MunicipalAppointmentsCache.fetch(input, fn -> run(input, &fetch_json/2) end)
      else
        run(input, fetcher)
      end
    else
      {:error, code} -> error(code, language)
    end
  end

  defp validate(args) when is_map(args) do
    service = args["service_id"]
    date = args["date"]

    cond do
      Enum.any?(Map.keys(args), &(&1 not in ["municipality", "service_id", "date", "language"])) ->
        {:error, "invalid_fields"}

      Map.get(args, "municipality", "ponte_de_lima") != "ponte_de_lima" ->
        {:error, "invalid_municipality"}

      Map.get(args, "language", "pt") not in ["pt", "en"] ->
        {:error, "invalid_language"}

      Map.has_key?(args, "service_id") and not (is_integer(service) and service > 0) ->
        {:error, "invalid_service_id"}

      Map.has_key?(args, "date") and (is_nil(service) or not valid_date?(date)) ->
        {:error, "invalid_date"}

      true ->
        {:ok, %{service_id: service, date: date, language: Map.get(args, "language", "pt")}}
    end
  end

  defp validate(_), do: {:error, "invalid_input"}

  defp valid_date?(date) when is_binary(date) do
    with true <- Regex.match?(~r/^\d{4}-\d{2}-\d{2}$/, date),
         {:ok, parsed} <- Date.from_iso8601(date) do
      Date.diff(parsed, Date.utc_today()) in 0..366
    else
      _ -> false
    end
  end

  defp valid_date?(_), do: false

  defp run(input, fetcher) do
    with {:ok, raw} <- fetcher.(@areas, %{"appointment_type" => "in_person", "allowed" => ""}),
         {:ok, areas} <- parse_areas(raw),
         {:ok, result} <- availability(input, areas, fetcher) do
      {:ok, Map.merge(base(input.language), result)}
    else
      {:error, :invalid_service_id} -> error("invalid_service_id", input.language)
      _ -> error("source_unavailable", input.language)
    end
  rescue
    _ -> error("source_unavailable", input.language)
  catch
    :exit, _ -> error("source_unavailable", input.language)
  end

  defp availability(%{service_id: nil}, areas, _fetcher),
    do: {:ok, %{status: "areas_listed", areas: areas}}

  defp availability(input, areas, fetcher) do
    case Enum.find(areas, &(&1.id == input.service_id)) do
      nil ->
        {:error, :invalid_service_id}

      area ->
        params = %{
          "customer_service_area_id" => area.id,
          "appointment_type" => "in_person",
          "operator_id" => ""
        }

        with {:ok, raw} <- fetcher.(@dates, params),
             {:ok, dates} <- parse_dates(raw),
             {:ok, result} <- date_result(input.date, dates, area.id, params, fetcher) do
          {:ok, Map.merge(result, %{service_id: area.id, service_name: area.name})}
        end
    end
  end

  defp date_result(nil, dates, _, _, _), do: {:ok, %{dates: dates, status: status(dates)}}

  defp date_result(date, dates, id, params, fetcher) do
    if date in dates do
      formatted = date |> Date.from_iso8601!() |> Calendar.strftime("%d/%m/%Y")

      with {:ok, raw} <- fetcher.(@slots, Map.put(params, "start_at_date", formatted)),
           {:ok, slots} <- parse_slots(raw, id, date) do
        {:ok, %{date: date, slots: slots, status: status(slots)}}
      end
    else
      {:ok, %{date: date, slots: [], status: "no_availability"}}
    end
  end

  defp parse_areas(items) when is_list(items) and length(items) <= 500 do
    collect(items, fn
      [name, id | _]
      when is_binary(name) and byte_size(name) in 1..500 and is_integer(id) and id > 0 ->
        {:ok, %{id: id, name: name}}

      _ ->
        {:error, :malformed}
    end)
  end

  defp parse_areas(_), do: {:error, :malformed}

  defp parse_dates(%{"dates" => dates}) when is_list(dates) and length(dates) <= 2000 do
    with {:ok, parsed} <-
           collect(dates, fn date ->
             if is_binary(date) and Regex.match?(~r/^\d{4}\/\d{2}\/\d{2}$/, date) do
               case Date.from_iso8601(String.replace(date, "/", "-")) do
                 {:ok, value} -> {:ok, Date.to_iso8601(value)}
                 _ -> {:error, :malformed}
               end
             else
               {:error, :malformed}
             end
           end) do
      {:ok, parsed |> Enum.filter(&valid_date?/1) |> Enum.uniq() |> Enum.sort()}
    end
  end

  defp parse_dates(_), do: {:error, :malformed}

  defp parse_slots(items, service_id, date) when is_list(items) and length(items) <= 1000 do
    prefix = String.replace(date, "-", "/")

    collect(items, fn
      %{"customer_service_area" => ^service_id, "start_at" => label} when is_binary(label) ->
        case Regex.run(
               ~r/^(\d{4}\/\d{2}\/\d{2}) das ([0-2]\d:[0-5]\d) às ([0-2]\d:[0-5]\d)$/,
               label
             ) do
          [_, ^prefix, start_time, end_time] ->
            if start_time < end_time and end_time < "24:00" do
              {:ok,
               %{date: date, starts_at: start_time, ends_at: end_time, timezone: "Europe/Lisbon"}}
            else
              {:error, :malformed}
            end

          _ ->
            {:error, :malformed}
        end

      _ ->
        {:error, :malformed}
    end)
  end

  defp parse_slots(_, _, _), do: {:error, :malformed}

  defp collect(items, fun) do
    Enum.reduce_while(items, {:ok, []}, fn item, {:ok, acc} ->
      case fun.(item) do
        {:ok, value} -> {:cont, {:ok, [value | acc]}}
        error -> {:halt, error}
      end
    end)
    |> case do
      {:ok, items} -> {:ok, Enum.reverse(items)}
      error -> error
    end
  end

  defp status([]), do: "no_availability"
  defp status(_), do: "available_at_check_time"

  defp base(language) do
    %{
      municipality: "ponte_de_lima",
      source: @portal,
      official_portal: @portal,
      checked_at: DateTime.utc_now() |> DateTime.to_iso8601(),
      date_window: %{
        from: Date.to_iso8601(Date.utc_today()),
        through: Date.to_iso8601(Date.add(Date.utc_today(), 366))
      },
      submitted: false,
      reserved: false,
      language: language,
      steps:
        if(language == "en",
          do:
            "Choose a service and date, then confirm and complete the booking on the official portal.",
          else: "Escolha o serviço e a data; confirme e conclua a marcação no portal oficial."
        ),
      warning:
        if(language == "en",
          do:
            "Public in-person availability only, observed at the stated time; it may change. No appointment has been reserved.",
          else:
            "Apenas disponibilidade pública de atendimento presencial, observada no momento indicado; pode mudar. Nenhuma marcação foi reservada."
        )
    }
  end

  @doc false
  def error(code, language) do
    {:error,
     Map.merge(base(language), %{
       status: "error",
       error: code,
       message:
         if(language == "en",
           do:
             "Unable to complete this query. Check the parameters or consult the official portal.",
           else:
             "Não foi possível concluir a consulta. Verifique os parâmetros ou consulte o portal oficial."
         )
     })}
  end

  # Private: callers cannot supply a host, path, operator or HTTP method.
  defp fetch_json(endpoint, params) do
    url = @base <> endpoint <> "?" <> URI.encode_query(params)

    headers = [
      {~c"user-agent", ~c"eCidadao/0.3 (+https://ecidadao.pt)"},
      {~c"accept", ~c"application/json"}
    ]

    options = [
      timeout: 8_000,
      connect_timeout: 4_000,
      autoredirect: false,
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        customize_hostname_check: [match_fun: :public_key.pkix_verify_hostname_match_fun(:https)]
      ]
    ]

    case :httpc.request(:get, {String.to_charlist(url), headers}, options,
           body_format: :binary,
           max_body_size: @limit,
           max_header_size: 16_384
         ) do
      {:ok, {{_, 200, _}, _, body}} when byte_size(body) <= @limit -> Jason.decode(body)
      _ -> {:error, :upstream}
    end
  end
end
