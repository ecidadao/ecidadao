defmodule Ecidadao.MunicipalAppointmentsTest do
  use ExUnit.Case, async: false
  alias Ecidadao.MunicipalAppointments, as: Appointments

  defp date, do: Date.utc_today() |> Date.add(2) |> Date.to_iso8601()
  defp upstream_date, do: String.replace(date(), "-", "/")

  defp fetcher(endpoint, params) do
    send(self(), {:fetch, endpoint, params})

    case endpoint do
      "get_avaible_customer_areas" ->
        {:ok, [["Consulta de Processo", 7, "private biography"]]}

      "get_available_dates" ->
        {:ok, %{"dates" => [upstream_date()], "form" => %{"session_token" => "secret"}}}

      "get_empty" ->
        {:ok,
         [
           %{
             "id" => 99,
             "customer_service_area" => 7,
             "start_at" => upstream_date() <> " das 09:30 às 10:30",
             "internal" => "secret"
           }
         ]}
    end
  end

  test "lists only public display names and IDs, without asserting appointment availability" do
    assert {:ok, result} = Appointments.lookup(%{}, &fetcher/2)
    assert result.areas == [%{id: 7, name: "Consulta de Processo"}]
    assert result.status == "areas_listed"
    assert result.municipality == "ponte_de_lima"
    assert result.submitted == false and result.reserved == false
    assert {:ok, _, 0} = DateTime.from_iso8601(result.checked_at)
    assert result.official_portal == "https://www.cm-pontedelima.pt/pages/1606"

    assert_received {:fetch, "get_avaible_customer_areas",
                     %{"appointment_type" => "in_person", "allowed" => ""}}

    refute_received {:fetch, "get_available_dates", _}
    refute Jason.encode!(result) =~ "biography"
  end

  test "normalizes dates and discards form configuration" do
    assert {:ok, result} =
             Appointments.lookup(%{"service_id" => 7, "language" => "en"}, &fetcher/2)

    assert result.dates == [date()]
    assert result.status == "available_at_check_time"
    assert result.service_id == 7
    assert result.steps =~ "official portal"
    assert result.warning =~ "No appointment"
    refute Jason.encode!(result) =~ "secret"

    assert_received {:fetch, "get_available_dates",
                     %{
                       "customer_service_area_id" => 7,
                       "appointment_type" => "in_person",
                       "operator_id" => ""
                     }}
  end

  test "returns only requested date slots, with local timezone and no booking identifiers" do
    assert {:ok, result} = Appointments.lookup(%{"service_id" => 7, "date" => date()}, &fetcher/2)

    assert result.slots == [
             %{date: date(), starts_at: "09:30", ends_at: "10:30", timezone: "Europe/Lisbon"}
           ]

    assert result.status == "available_at_check_time"
    expected = Date.utc_today() |> Date.add(2) |> Calendar.strftime("%d/%m/%Y")
    assert_received {:fetch, "get_empty", %{"start_at_date" => ^expected}}
    refute Jason.encode!(result) =~ "secret"
  end

  test "rejects unknown keys and PII without echo or network access" do
    for input <- [
          %{"email" => "private@example.com"},
          %{service_id: 7},
          %{"host" => "https://evil.test"},
          %{"operator_id" => 1},
          %{"path" => "/anything"},
          %{"private@example.com" => "secret"}
        ] do
      assert {:error, result} = Appointments.lookup(input, &fetcher/2)
      assert result.error == "invalid_fields"
      refute Jason.encode!(result) =~ "private@example.com"
    end

    refute_received {:fetch, _, _}
  end

  test "strict input types and date bounds are checked before fetching" do
    for input <- [
          nil,
          [],
          %{"municipality" => "maia"},
          %{"language" => "fr"},
          %{"service_id" => "7"},
          %{"service_id" => 0},
          %{"service_id" => nil},
          %{"date" => date()},
          %{"service_id" => 7, "date" => nil},
          %{"service_id" => 7, "date" => "2026-02-30"},
          %{"service_id" => 7, "date" => String.replace(date(), "-", "/")},
          %{"service_id" => 7, "date" => Date.to_iso8601(Date.add(Date.utc_today(), -1))},
          %{"service_id" => 7, "date" => Date.to_iso8601(Date.add(Date.utc_today(), 367))}
        ] do
      assert {:error, %{status: "error"}} = Appointments.lookup(input, &fetcher/2)
    end

    refute_received {:fetch, _, _}
  end

  test "validates selected service against current public areas before dependent requests" do
    assert {:error, %{error: "invalid_service_id"}} =
             Appointments.lookup(%{"service_id" => 99}, &fetcher/2)

    assert_received {:fetch, "get_avaible_customer_areas", _}
    refute_received {:fetch, "get_available_dates", _}
    refute_received {:fetch, "get_empty", _}
  end

  test "empty areas are an empty directory, never proof of no appointment availability" do
    assert {:ok, %{status: "areas_listed", areas: []}} =
             Appointments.lookup(%{}, fn _, _ -> {:ok, []} end)
  end

  test "empty dates and slots are successful no-availability observations" do
    for date_arg <- [nil, date()] do
      args = if date_arg, do: %{"service_id" => 7, "date" => date_arg}, else: %{"service_id" => 7}

      fetch = fn
        "get_available_dates", _ -> {:ok, %{"dates" => []}}
        endpoint, params -> fetcher(endpoint, params)
      end

      assert {:ok, %{status: "no_availability"}} = Appointments.lookup(args, fetch)
      refute_received {:fetch, "get_empty", _}
    end

    fetch = fn
      "get_empty", _ -> {:ok, []}
      endpoint, params -> fetcher(endpoint, params)
    end

    assert {:ok, %{status: "no_availability", slots: []}} =
             Appointments.lookup(%{"service_id" => 7, "date" => date()}, fetch)
  end

  test "upstream errors, exceptions and malformed data never look like no availability or echo details" do
    for response <- [
          {:error, :timeout},
          {:error, "secret token"},
          {:ok, %{}},
          {:ok, [["Area", "7"]]},
          {:ok, [["Area", 7], nil]}
        ] do
      assert {:error, result} = Appointments.lookup(%{}, fn _, _ -> response end)
      assert result.error == "source_unavailable"
      assert result.status == "error"
      refute Jason.encode!(result) =~ "secret"
    end

    assert {:error, %{error: "source_unavailable"}} =
             Appointments.lookup(%{}, fn _, _ -> raise "secret" end)
  end

  test "malformed dates are rejected rather than silently interpreted as empty" do
    for raw <- [
          %{},
          %{"dates" => nil},
          %{"dates" => ["2026/02/30"]},
          %{"dates" => [upstream_date(), "bad"]}
        ] do
      fetch = fn
        "get_available_dates", _ -> {:ok, raw}
        endpoint, params -> fetcher(endpoint, params)
      end

      assert {:error, %{error: "source_unavailable"}} =
               Appointments.lookup(%{"service_id" => 7}, fetch)
    end
  end

  test "rejects slots for another date or service and invalid times" do
    for slot <- [
          %{"customer_service_area" => 8, "start_at" => upstream_date() <> " das 09:30 às 10:30"},
          %{"customer_service_area" => 7, "start_at" => "2000/01/01 das 09:30 às 10:30"},
          %{"customer_service_area" => 7, "start_at" => upstream_date() <> " das 29:30 às 30:30"},
          %{"customer_service_area" => 7, "start_at" => upstream_date() <> " das 10:30 às 09:30"},
          %{}
        ] do
      fetch = fn
        "get_empty", _ -> {:ok, [slot]}
        endpoint, params -> fetcher(endpoint, params)
      end

      assert {:error, %{error: "source_unavailable"}} =
               Appointments.lookup(%{"service_id" => 7, "date" => date()}, fetch)
    end
  end

  test "cache preserves the observation timestamp and rejects rapid different requests" do
    if Process.whereis(Ecidadao.MunicipalAppointmentsCache) == nil do
      start_supervised!(Ecidadao.MunicipalAppointmentsCache)
    end

    :sys.replace_state(Ecidadao.MunicipalAppointmentsCache, fn _ -> %{entries: %{}, last: nil} end)

    input = %{service_id: nil, date: nil, language: "pt"}
    result = {:ok, %{checked_at: "2026-11-27T12:00:00Z"}}
    assert ^result = Ecidadao.MunicipalAppointmentsCache.fetch(input, fn -> result end)

    assert ^result =
             Ecidadao.MunicipalAppointmentsCache.fetch(input, fn -> flunk("cache miss") end)

    assert {:error, %{error: "rate_limited"}} =
             Ecidadao.MunicipalAppointmentsCache.fetch(%{input | service_id: 7}, fn ->
               flunk("rate limit missed")
             end)

    :sys.replace_state(Ecidadao.MunicipalAppointmentsCache, fn state ->
      expired = System.monotonic_time(:millisecond) - 1

      %{
        state
        | entries: Map.new(state.entries, fn {key, {_, result}} -> {key, {expired, result}} end),
          last: nil
      }
    end)

    assert {:error, :timeout} =
             Ecidadao.MunicipalAppointmentsCache.fetch(input, fn -> {:error, :timeout} end)

    assert :sys.get_state(Ecidadao.MunicipalAppointmentsCache).entries == %{}
  end
end
