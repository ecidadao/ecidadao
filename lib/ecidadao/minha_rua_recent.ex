defmodule Ecidadao.MinhaRuaRecent do
  @moduledoc false
  use GenServer

  @ttl_ms 120_000
  @max_stale_ms 600_000

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def get, do: GenServer.call(__MODULE__, :get, 9_000)

  @impl true
  def init(_), do: {:ok, %{value: nil, fetched_at_ms: 0, source_at_ms: 0, stale: false}}

  @impl true
  def handle_call(:get, _from, state) do
    now = System.monotonic_time(:millisecond)

    if state.value && now - state.fetched_at_ms < @ttl_ms do
      {:reply, {:ok, Map.put(state.value, :stale, state.stale)}, state}
    else
      case Ecidadao.MinhaRua.fetch_latest() do
        {:ok, value} ->
          {:reply, {:ok, Map.put(value, :stale, false)},
           %{value: value, fetched_at_ms: now, source_at_ms: now, stale: false}}

        {:error, _reason} when state.value != nil and now - state.source_at_ms <= @max_stale_ms ->
          {:reply, {:ok, Map.put(state.value, :stale, true)},
           %{state | fetched_at_ms: now, stale: true}}

        {:error, reason} ->
          {:reply, {:error, reason}, state}
      end
    end
  end
end
