defmodule Ecidadao.Sns24Test do
  use ExUnit.Case, async: true
  alias Ecidadao.{MCP, Sns24}

  test "all public routes return complete bilingual guidance without account access" do
    for service <- Sns24.services(),
        language <- ["pt", "en"],
        channel <- ["portal", "app", "both"] do
      assert {:reply, %{result: response}} =
               MCP.public_handle(%{
                 "jsonrpc" => "2.0",
                 "id" => 1,
                 "method" => "tools/call",
                 "params" => %{
                   "name" => "sns24_service_guidance",
                   "arguments" => %{
                     "service" => service,
                     "language" => language,
                     "channel" => channel
                   }
                 }
               })

      refute Map.get(response, :isError, false)
      data = response.structuredContent
      assert data.status == "guidance_only"
      assert data.submitted == false
      assert data.language == language
      assert data.source =~ "https://www.sns24.gov.pt/pt/servico/"
      assert [%{text: text}] = response.content
      assert text =~ data.source
      assert text =~ data.confirmation
      assert text =~ data.alternative
      assert text =~ if(language == "en", do: "Guidance only", else: "Apenas orientação")
      if channel == "app", do: refute(data.navigation =~ "No Portal SNS 24")
    end
  end

  test "unrecognised fields, unsafe values and personal data are rejected without echoing" do
    for args <- [
          nil,
          [],
          "exams",
          %{},
          %{"service" => "book_now"},
          %{"service" => "exams", "language" => "xx"},
          %{"service" => "exams", "channel" => "sms"},
          %{"service" => "exams", "patient" => "private-marker"},
          %{"service" => "<script>private-marker</script>"}
        ] do
      assert {:error, errors} = Sns24.guide(args)
      refute inspect(errors) =~ "private-marker"
    end
  end

  test "requests are not presented as confirmed appointments or prescriptions" do
    assert {:ok, exams} = Sns24.guide(%{"service" => "exams", "language" => "en"})
    assert exams.confirmation =~ "does not reserve a slot"
    assert {:ok, medication} = Sns24.guide(%{"service" => "medication"})
    assert medication.confirmation =~ "aprovação"
    assert {:ok, appointments} = Sns24.guide(%{"service" => "appointments"})
    assert appointments.confirmation =~ "não garante consulta para amanhã"
  end
end
