defmodule Ecidadao.MunicipalAppointmentsCache do
  @moduledoc "Bounded 30-second result cache and serialized admission for municipal queries."
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def fetch(input, fun) do
    GenServer.call(__MODULE__, {:fetch, input, fun}, 30_000)
  catch
    :exit, _ -> Ecidadao.MunicipalAppointments.error("source_unavailable", input.language)
  end

  @impl true
  def init(_), do: {:ok, %{entries: %{}, last: nil}}

  @impl true
  def handle_call({:fetch, key, fun}, _from, state) do
    now = System.monotonic_time(:millisecond)
    entries = Map.filter(state.entries, fn {_, {expires, _}} -> expires > now end)

    case entries[key] do
      {_, result} ->
        {:reply, result, %{state | entries: entries}}

      nil ->
        if state.last != nil and now - state.last < 1_000 do
          {:reply, Ecidadao.MunicipalAppointments.error("rate_limited", key.language),
           %{state | entries: entries}}
        else
          result = fun.()
          entries = if map_size(entries) >= 128, do: %{}, else: entries

          entries =
            case result do
              {:ok, _} ->
                Map.put(entries, key, {System.monotonic_time(:millisecond) + 30_000, result})

              _ ->
                entries
            end

          {:reply, result, %{entries: entries, last: System.monotonic_time(:millisecond)}}
        end
    end
  end
end
