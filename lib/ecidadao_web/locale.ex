defmodule EcidadaoWeb.Locale do
  @moduledoc "Website translations and request language selection. API payloads remain unchanged."
  import Plug.Conn

  @external_resource Path.expand("../../priv/locales/en.json", __DIR__)
  @english @external_resource |> File.read!() |> Jason.decode!()

  def text(value, "en"), do: Map.get(@english, value, value)
  def text(value, _), do: value
  def t(value, locale), do: value |> text(locale) |> Plug.HTML.html_escape()
  def tj(value, locale), do: value |> text(locale) |> script_json()

  # JSON embedded in HTML must not be able to close the script element.
  def script_json(value) do
    value
    |> Jason.encode!()
    |> String.replace("<", "\\u003c")
    |> String.replace(">", "\\u003e")
    |> String.replace("&", "\\u0026")
  end

  def client_messages("en"),
    do:
      script_json(
        Map.take(@english, [
          "Escolha reclamação, elogio ou sugestão.",
          "Máximo de 200 caracteres.",
          "Máximo de 10 caracteres.",
          "Máximo de 5000 caracteres.",
          "Máximo de 1500 caracteres.",
          "Envie os dados do pedido.",
          "Use texto neste campo.",
          "Use texto UTF-8 válido.",
          "Use uma data válida AAAA-MM-DD.",
          "type",
          "organisation",
          "location",
          "Campo obrigatório.",
          "Endereço de email inválido.",
          "Use a data AAAA-MM-DD.",
          "Escolha uma categoria da lista oficial.",
          "Escolha um distrito válido.",
          "Indique a entidade (máximo 120 caracteres).",
          "Indique o tipo de senha (máximo 120 caracteres).",
          "Indique latitude válida.",
          "Indique longitude válida.",
          "Escolha um raio de 1 a 100 km.",
          "Não encontrado no distrito. Confirme no portal oficial.",
          "Escolha um nome mais específico.",
          "Resposta inesperada do SIGA.",
          "Aberto",
          "Fechado",
          "business_name",
          "reference",
          "consumer_name",
          "consumer_email",
          "incident_date",
          "description",
          "requested_resolution",
          "district",
          "municipality",
          "parish",
          "address",
          "category",
          "subject",
          "message",
          "tax_area",
          "entity",
          "ticket_type",
          "latitude",
          "longitude",
          "radius_km",
          "source",
          "input"
        ])
      )

  def client_messages(_), do: "{}"

  def select(conn) do
    conn = conn |> fetch_query_params() |> fetch_cookies()
    explicit = conn.query_params["lang"]
    saved = conn.req_cookies["ecidadao_language"]

    locale =
      cond do
        explicit in ["pt", "en"] -> explicit
        saved in ["pt", "en"] -> saved
        true -> browser_language(get_req_header(conn, "accept-language"))
      end

    conn =
      if explicit in ["pt", "en"] do
        put_resp_cookie(conn, "ecidadao_language", locale,
          max_age: 31_536_000,
          path: "/",
          same_site: "Lax",
          http_only: true,
          secure: conn.scheme == :https
        )
      else
        conn
      end

    {conn
     |> put_resp_header("content-language", locale)
     |> put_resp_header("vary", "accept-language, cookie")
     |> put_resp_header("cache-control", "private, no-cache"), locale}
  end

  defp browser_language(headers) do
    headers
    |> Enum.join(",")
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.map(fn {item, index} ->
      [language | params] = String.split(String.downcase(String.trim(item)), ";")

      quality =
        Enum.find_value(params, 1.0, fn param ->
          case String.split(String.trim(param), "=", parts: 2) do
            ["q", value] ->
              case Float.parse(value) do
                {q, ""} when q >= 0 and q <= 1 -> q
                _ -> 0.0
              end

            _ ->
              nil
          end
        end)

      {language |> String.split("-") |> hd(), quality, index}
    end)
    |> Enum.filter(fn {language, q, _} -> language in ["pt", "en"] and q > 0 end)
    |> Enum.sort_by(fn {_, q, index} -> {-q, index} end)
    |> case do
      [{language, _, _} | _] -> language
      [] -> "pt"
    end
  end
end
