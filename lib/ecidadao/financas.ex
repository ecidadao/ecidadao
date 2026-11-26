defmodule Ecidadao.Financas do
  @moduledoc "Guides users to official tax services and prepares an e-balcão draft."

  @portal "https://www.portaldasfinancas.gov.pt/at/html/index.html"
  @ebalcao "https://sitfiscal.portaldasfinancas.gov.pt/ebalcao/formularioContacto"

  @services %{
    "ebalcao" =>
      {"Atendimento e-balcão", @ebalcao,
       "Autentique-se, escolha Imposto ou área, Tipo de questão e Questão, reveja o pedido e registe-o no portal."},
    "irs" =>
      {"IRS", @portal,
       "No portal, pesquise por IRS e escolha o serviço adequado ao que pretende fazer."},
    "imi" =>
      {"IMI", @portal,
       "No portal, pesquise por IMI e confirme o imóvel, o documento ou o pagamento pretendido."},
    "pagamentos" =>
      {"Pagamentos", @portal,
       "No portal, pesquise por pagamentos e confirme a referência e o prazo na sua área autenticada."},
    "certidoes" =>
      {"Certidões", @portal,
       "No portal, pesquise pela certidão pretendida e confirme os dados na sua área autenticada."},
    "outro" =>
      {"Outros assuntos", @portal,
       "Use a pesquisa do portal para identificar o serviço; se precisar de esclarecimento individual, use o e-balcão."}
  }

  def guide(%{"service" => service}) when is_binary(service) do
    key = service |> String.trim() |> String.downcase()

    case Map.fetch(@services, key) do
      {:ok, {label, url, steps}} ->
        {:ok,
         %{
           service: key,
           label: label,
           official_portal: url,
           steps: steps,
           authentication_required: key == "ebalcao" or key != "outro",
           status: "orientacao_sem_acesso_a_conta",
           warning:
             "O eCidadão não acede à sua conta, não consulta dados fiscais e não submete pedidos."
         }}

      :error ->
        {:error,
         [
           %{
             field: "service",
             message: "Escolha ebalcao, irs, imi, pagamentos, certidoes ou outro."
           }
         ]}
    end
  end

  def guide(_), do: {:error, [%{field: "service", message: "Indique o serviço pretendido."}]}

  def prepare_ebalcao(input) when is_map(input) do
    subject = clean(Map.get(input, "subject"))
    message = clean(Map.get(input, "message"))
    area = clean(Map.get(input, "tax_area"))

    errors =
      for {field, value, limit} <- [
            {"subject", subject, 200},
            {"message", message, 5000},
            {"tax_area", area, 100}
          ],
          (value == "" and field != "tax_area") or String.length(value) > limit do
        %{
          field: field,
          message:
            if(value == "", do: "Campo obrigatório.", else: "Máximo de #{limit} caracteres.")
        }
      end

    if errors == [] do
      draft =
        [
          "RASCUNHO PARA O E-BALCÃO — NÃO SUBMETIDO",
          if(area == "",
            do: nil,
            else: "Área sugerida: #{area} (confirme a categoria no portal)"
          ),
          "Assunto: #{subject}",
          "Mensagem:\n#{message}",
          "Apresente e confirme o pedido em #{@ebalcao}. Guarde o número emitido pela AT."
        ]
        |> Enum.reject(&is_nil/1)
        |> Enum.join("\n\n")

      {:ok,
       %{
         status: "rascunho_nao_submetido",
         fields: %{subject: subject, message: message, tax_area: area},
         draft: draft,
         official_portal: @ebalcao,
         next_step:
           "Autentique-se no portal oficial, escolha a categoria correta, reveja e registe a questão."
       }}
    else
      {:error, errors}
    end
  end

  def prepare_ebalcao(_), do: {:error, [%{field: "input", message: "Envie os dados do pedido."}]}

  defp clean(value) when is_binary(value), do: String.trim(value)
  defp clean(_), do: ""
end
