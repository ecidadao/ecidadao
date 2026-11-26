defmodule Ecidadao.FinancasTest do
  use ExUnit.Case, async: true
  alias Ecidadao.Financas

  test "prepares an e-balcão draft without claiming submission" do
    assert {:ok, draft} =
             Financas.prepare_ebalcao(%{
               "subject" => "Dúvida sobre IMI",
               "message" => "Pretendo esclarecer o documento de pagamento.",
               "tax_area" => "IMI"
             })

    assert draft.status == "rascunho_nao_submetido"
    assert draft.draft =~ "NÃO SUBMETIDO"
    assert draft.draft =~ "Dúvida sobre IMI"
    assert draft.official_portal =~ "ebalcao/formularioContacto"
  end

  test "rejects an empty question" do
    assert {:error, errors} = Financas.prepare_ebalcao(%{"subject" => "", "message" => ""})
    assert Enum.map(errors, & &1.field) |> Enum.sort() == ["message", "subject"]
  end
end
