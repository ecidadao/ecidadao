defmodule EcidadaoWeb.CivicPageTest do
  use ExUnit.Case, async: true
  alias EcidadaoWeb.CivicPage

  test "municipal pages render initial services, source dates and localized search" do
    for locale <- ["pt", "en"] do
      html = CivicPage.municipalities(locale)
      assert length(Regex.scan(~r/data-service-id=/, html)) == 12
      assert html =~ "2026-11-27"
      assert html =~ "/vagas?lang=#{locale}"
      assert html =~ "maxlength=\"160\""
      assert html =~ "textContent"
      assert html =~ "replaceChildren"
      refute html =~ "innerHTML"

      assert html =~
               if(locale == "en",
                 do: "Services in your municipality",
                 else: "Serviços do seu município"
               )
    end
  end

  test "support pages include every guide and preserve separate dated phases" do
    for locale <- ["pt", "en"] do
      html = CivicPage.public_support(locale)
      assert length(Regex.scan(~r/data-support-id=/, html)) == 7
      assert html =~ "data-phase=\"supplier_payment_request\""
      assert html =~ "data-phase=\"existing_beneficiary_expression_of_interest\""
      assert html =~ "2024-10-31"
      assert html =~ "2027-01-25"
      refute html =~ "<input"
      refute html =~ "<textarea"
      refute html =~ "within_published_deadline"

      assert html =~
               if(locale == "en",
                 do: "Payment request — suppliers",
                 else: "Pedido de pagamento — fornecedores"
               )
    end
  end
end
