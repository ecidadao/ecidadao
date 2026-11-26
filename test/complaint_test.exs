defmodule Ecidadao.ComplaintTest do
  use ExUnit.Case, async: true
  alias Ecidadao.Complaint

  test "prepares a draft with an explicit non-submission warning" do
    assert {:ok, result} =
             Complaint.prepare(%{
               "business_name" => " Loja Exemplo ",
               "description" => "Recebi um artigo avariado.",
               "requested_resolution" => "Quero a substituição."
             })

    assert result.fields["business_name"] == "Loja Exemplo"
    assert result.status == "rascunho_nao_submetido"
    assert result.draft =~ "AINDA NÃO SUBMETIDO"
    assert result.draft =~ "https://www.livroreclamacoes.pt/Inicio/"
  end

  test "rejects missing fields and malformed optional data" do
    assert {:error, errors} =
             Complaint.prepare(%{
               "consumer_email" => "invalido",
               "incident_date" => "2026-02-30"
             })

    assert Enum.any?(errors, &(&1.field == "business_name"))
    assert Enum.any?(errors, &(&1.field == "description"))
    assert Enum.any?(errors, &(&1.field == "consumer_email"))
    assert Enum.any?(errors, &(&1.field == "incident_date"))
  end
end
