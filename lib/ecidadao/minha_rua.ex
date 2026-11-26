defmodule Ecidadao.MinhaRua do
  @moduledoc "Prepares public-space reports and reads the latest public A Minha Rua entries."

  @report_url "https://servicos.arte.gov.pt/Portal/AMR/situationReport.aspx"
  @list_url "https://servicos.arte.gov.pt/Portal/AMR/situationsList.aspx"
  @details_base "https://servicos.arte.gov.pt/Portal/AMR/situationDetails.aspx?idproblem="

  @categories [
    "Acessos para Cidadãos com Mobilidade Reduzida",
    "Animais Abandonados",
    "Conservação da Iluminação Pública",
    "Conservação das Ruas e Pavimento",
    "Conservação de Parque Escolar",
    "Estacionamento de Veículos",
    "Limpeza de Valetas, Bermas e Caminhos",
    "Limpeza e Conservação de Espaços Públicos",
    "Manutenção de Ciclovias",
    "Manutenção e Limpeza de Contentores e Ecopontos",
    "Manutenção, Rega e Limpeza de Jardins",
    "Nomes ou Numeração de Ruas",
    "Poluição Sonora",
    "Publicidade, Outdoors e Cartazes",
    "Recolha de Lixo",
    "Saneamento, Ruturas de Águas ou Desvio de Tampas",
    "Sinalização de Trânsito"
  ]

  @required ~w(district municipality parish address category subject description)
  @limits %{
    "district" => 100,
    "municipality" => 100,
    "parish" => 120,
    "address" => 2000,
    "category" => 100,
    "subject" => 255,
    "description" => 5000
  }

  def report_url, do: @report_url
  def list_url, do: @list_url
  def categories, do: @categories

  def prepare(input) when is_map(input) do
    fields = Map.new(@required, fn key -> {key, clean(Map.get(input, key))} end)

    errors =
      for field <- @required, fields[field] == "" do
        %{field: field, message: "Campo obrigatório."}
      end ++
        for {field, limit} <- @limits, String.length(fields[field]) > limit do
          %{field: field, message: "Máximo de #{limit} caracteres."}
        end

    errors =
      if fields["category"] != "" and fields["category"] not in @categories do
        errors ++ [%{field: "category", message: "Escolha uma categoria da lista oficial."}]
      else
        errors
      end

    if errors == [] do
      {:ok,
       %{
         fields: fields,
         draft: format(fields),
         status: "rascunho_nao_submetido",
         official_portal: @report_url,
         next_step:
           "Abra o formulário oficial, copie os campos, indique o seu nome e email apenas nesse portal, leia os termos, resolva o reCAPTCHA e confirme o envio. Guarde o número do pedido."
       }}
    else
      {:error, errors}
    end
  end

  def prepare(_),
    do: {:error, [%{field: "input", message: "Envie um objeto com os dados da ocorrência."}]}

  def latest, do: Ecidadao.MinhaRuaRecent.get()

  def fetch_latest do
    options = [
      timeout: 6_000,
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        customize_hostname_check: [match_fun: :public_key.pkix_verify_hostname_match_fun(:https)]
      ]
    ]

    request =
      {String.to_charlist(@list_url), [{~c"user-agent", ~c"eCidadao/0.2 (+https://ecidadao.pt)"}]}

    case :httpc.request(:get, request, options, body_format: :binary) do
      {:ok, {{_, 200, _}, _, body}} when byte_size(body) <= 500_000 ->
        case parse_latest(body) do
          [] ->
            {:error, :unexpected_response}

          reports ->
            {:ok,
             %{
               reports: reports,
               source: @list_url,
               fetched_at: DateTime.utc_now() |> DateTime.to_iso8601()
             }}
        end

      {:ok, {{_, 200, _}, _, _}} ->
        {:error, :response_too_large}

      {:ok, {{_, status, _}, _, _}} ->
        {:error, {:http_status, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def parse_latest(html) when is_binary(html) do
    with [_, table] <-
           Regex.run(
             ~r/<table\b[^>]*id="ctl00_ContentBody_gvSituationsList"[^>]*>(.*?)(?:<\/table>)/s,
             html
           ) do
      Regex.scan(~r/<tr\b[^>]*>(.*?)<\/tr>/s, table, capture: :all_but_first)
      |> Enum.flat_map(fn [row] -> parse_row(row) end)
      |> Enum.take(10)
    else
      _ -> []
    end
  end

  defp parse_row(row) do
    cells =
      Regex.scan(~r/<td\b[^>]*>(.*?)<\/td>/s, row, capture: :all_but_first)
      |> Enum.map(fn [cell] -> plain_text(cell) end)

    case {Regex.run(~r/situationDetails\.aspx\?idproblem=(\d+)/, row), cells} do
      {[_, id], [_, date, subject, address, locality, status | _]} ->
        [
          %{
            id: id,
            date: date,
            subject: subject,
            address: address,
            locality: locality,
            status: status,
            official_url: @details_base <> id
          }
        ]

      _ ->
        []
    end
  end

  defp plain_text(html) do
    html
    |> String.replace(~r/<[^>]*>/s, " ")
    |> then(
      &Regex.replace(~r/&#(\d+);/, &1, fn _, number ->
        case Integer.parse(number) do
          {codepoint, ""}
          when codepoint >= 0 and codepoint <= 0x10FFFF and
                 (codepoint < 0xD800 or codepoint > 0xDFFF) ->
            <<codepoint::utf8>>

          _ ->
            ""
        end
      end)
    )
    |> String.replace("&amp;", "&")
    |> String.replace("&quot;", "\"")
    |> String.replace("&apos;", "'")
    |> String.replace("&nbsp;", " ")
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace(~r/\s+/u, " ")
    |> String.trim()
  end

  defp clean(value) when is_binary(value), do: String.trim(value)
  defp clean(_), do: ""

  defp format(fields) do
    """
    OCORRÊNCIA NO ESPAÇO PÚBLICO — RASCUNHO NÃO SUBMETIDO
    Distrito: #{fields["district"]}
    Município: #{fields["municipality"]}
    Freguesia: #{fields["parish"]}
    Morada da ocorrência: #{fields["address"]}
    Categoria: #{fields["category"]}
    Assunto: #{fields["subject"]}

    Descrição:
    #{fields["description"]}

    Formulário oficial: #{@report_url}
    A morada e a descrição podem ficar públicas no portal. Não inclua dados pessoais na descrição.
    Este rascunho não foi enviado à autarquia.
    """
    |> String.trim()
  end
end
