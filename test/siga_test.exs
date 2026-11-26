defmodule Ecidadao.SigaTest do
  use ExUnit.Case, async: true
  alias Ecidadao.Siga

  test "orders open queues by published wait and filters by radius without sending location" do
    parent = self()

    fetcher = fn path, params ->
      send(parent, {path, params})

      case path do
        "/Senhas/GetEntidadesNoDistrito" ->
          {:ok,
           [
             %{
               "id" => 146,
               "idInstituicao" => 10,
               "nome" => "Autoridade Tributária e Aduaneira - Finanças"
             }
           ]}

        "/Senhas/GetSenhas" ->
          {:ok, [%{"id" => 885, "nome" => "Atendimento Geral"}]}

        "/Senhas/GetLocais" ->
          {:ok,
           [
             place("Fechado", 41.18, -8.69, "FECHADO", 0),
             place("Rápido", 41.19, -8.69, "ABERTO", 120),
             place("Lento", 41.20, -8.69, "ABERTO", 1800),
             place("Longe", 42.5, -8.69, "ABERTO", 0)
           ]}
      end
    end

    assert {:ok, result} =
             Siga.compare(
               %{
                 "district" => "Porto",
                 "entity" => "Autoridade Tributária",
                 "ticket_type" => "Atendimento Geral",
                 "latitude" => 41.18,
                 "longitude" => -8.69,
                 "radius_km" => 40
               },
               fetcher
             )

    assert result.fastest_reported_queue == "Rápido"
    assert Enum.map(result.locations, & &1.name) == ["Rápido", "Lento", "Fechado"]
    assert hd(result.locations).wait_minutes == 2
    assert result.status == "consulta_publica_nao_reserva"

    for _ <- 1..3 do
      assert_receive {_, params}
      refute Map.has_key?(params, "latitude")
      assert params["Latitude"] in [nil, 0]
    end
  end

  test "requires a confirmed location for a radius search" do
    assert {:error, errors} =
             Siga.compare(%{"district" => "Porto", "entity" => "AT", "ticket_type" => "Geral"})

    assert Enum.any?(errors, &(&1.field == "latitude"))
    assert Enum.any?(errors, &(&1.field == "longitude"))
  end

  defp place(name, lat, lon, state, wait) do
    %{
      "nome" => name,
      "morada" => "Rua Exemplo",
      "latitude" => lat,
      "longitude" => lon,
      "servico" => %{
        "estado" => state,
        "tempoRealEspera" => wait,
        "utentesEmEspera" => 2,
        "senhaWeb" => true
      }
    }
  end
end
