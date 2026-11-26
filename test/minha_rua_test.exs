defmodule Ecidadao.MinhaRuaTest do
  use ExUnit.Case, async: true
  alias Ecidadao.MinhaRua

  test "rejects an unknown category before preparing a report" do
    assert {:error, errors} =
             MinhaRua.prepare(%{
               "district" => "Porto",
               "municipality" => "Matosinhos",
               "parish" => "Matosinhos",
               "address" => "Rua Exemplo",
               "category" => "Outra",
               "subject" => "Problema",
               "description" => "Descrição"
             })

    assert Enum.any?(errors, &(&1.field == "category"))
  end

  test "extracts factual fields and official URL from the public list" do
    html = ~S"""
    <table id="ctl00_ContentBody_gvSituationsList">
      <tr><th>Nº Pedido</th></tr>
      <tr><td onclick="navigateTo('situationDetails.aspx?idproblem=12345');">12345</td>
      <td>09.11.2026</td><td>Ilumina&#231;&#227;o &amp; seguran&#231;a</td>
      <td>Rua Exemplo</td><td>Porto</td><td>Submetido</td></tr>
    </table>
    """

    assert [%{id: "12345", subject: "Iluminação & segurança", locality: "Porto"} = report] =
             MinhaRua.parse_latest(html)

    assert report.official_url =~ "idproblem=12345"
  end
end
