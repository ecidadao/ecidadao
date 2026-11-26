defmodule Ecidadao.SigaCache do
  @moduledoc "Short-lived cache for public SIGA queue requests."
  use GenServer

  @table :ecidadao_siga_cache

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def fetch(path, params) do
    key = {path, params |> Enum.sort()}
    now = System.monotonic_time(:millisecond)

    case :ets.lookup(@table, key) do
      [{^key, expires, value}] when expires > now ->
        {:ok, value}

      _ ->
        case Ecidadao.Siga.fetch_json(path, params) do
          {:ok, value} = result ->
            ttl = if path == "/Senhas/GetLocais", do: 30_000, else: 600_000
            :ets.insert(@table, {key, now + ttl, value})
            result

          error ->
            error
        end
    end
  end

  @impl true
  def init(state) do
    :ets.new(@table, [:named_table, :public, :set, read_concurrency: true])
    Process.send_after(self(), :purge, 600_000)
    {:ok, state}
  end

  @impl true
  def handle_info(:purge, state) do
    now = System.monotonic_time(:millisecond)
    :ets.select_delete(@table, [{{:_, :"$1", :_}, [{:<, :"$1", now}], [true]}])
    Process.send_after(self(), :purge, 600_000)
    {:noreply, state}
  end
end
