defmodule Ecidadao.ObservationTest do
  use ExUnit.Case, async: true
  alias Ecidadao.Observation

  test "does not guess the responsible public service" do
    assert {:ok, preview} =
             Observation.preview(%{
               "observations" => "Uma placa de atendimento está caída no chão.",
               "context_hint" => "public_service"
             })

    assert preview.suggested_channel == "por determinar"
    assert preview.location_confirmed == false
    assert preview.next_question =~ "serviço público"
  end

  test "requires observable facts" do
    assert {:error, errors} = Observation.preview(%{"context_hint" => "street"})
    assert Enum.any?(errors, &(&1.field == "observations"))
  end
end
