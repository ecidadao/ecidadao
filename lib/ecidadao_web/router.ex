defmodule EcidadaoWeb.Router do
  use Plug.Router
  import Plug.Conn
  alias Ecidadao.{Complaint, Financas, MCP, MinhaRua, Siga}

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("text/html", "utf-8")
    |> send_resp(200, EcidadaoWeb.Page.landing())
  end

  get "/reclamacoes" do
    conn
    |> put_resp_content_type("text/html", "utf-8")
    |> send_resp(200, EcidadaoWeb.Page.complaints())
  end

  get "/a-minha-rua" do
    conn
    |> put_resp_content_type("text/html", "utf-8")
    |> send_resp(200, EcidadaoWeb.Page.minha_rua())
  end

  get "/siga" do
    conn |> put_resp_content_type("text/html", "utf-8") |> send_resp(200, EcidadaoWeb.Page.siga())
  end

  get "/financas" do
    conn
    |> put_resp_content_type("text/html", "utf-8")
    |> send_resp(200, EcidadaoWeb.Page.financas())
  end

  get "/como-usar" do
    conn
    |> put_resp_content_type("text/html", "utf-8")
    |> send_resp(200, EcidadaoWeb.Page.how_to_use())
  end

  get "/privacidade" do
    conn
    |> put_resp_content_type("text/html", "utf-8")
    |> send_resp(200, EcidadaoWeb.Page.privacy())
  end

  get "/termos" do
    conn
    |> put_resp_content_type("text/html", "utf-8")
    |> send_resp(200, EcidadaoWeb.Page.terms())
  end

  get "/apoio" do
    conn
    |> put_resp_content_type("text/html", "utf-8")
    |> send_resp(200, EcidadaoWeb.Page.support())
  end

  get "/health" do
    json(conn, 200, %{status: "ok", revision: System.get_env("RELEASE_SHA", "development")})
  end

  get "/.well-known/openai-apps-challenge" do
    case System.get_env("OPENAI_APPS_CHALLENGE") do
      token when is_binary(token) and byte_size(token) > 0 ->
        conn |> put_resp_content_type("text/plain", "utf-8") |> send_resp(200, token)

      _ ->
        send_resp(conn, 404, "Não encontrado")
    end
  end

  post "/api/complaints/prepare" do
    case Complaint.prepare(conn.body_params) do
      {:ok, draft} -> json(conn, 200, draft)
      {:error, errors} -> json(conn, 422, %{errors: errors})
    end
  end

  post "/api/street-reports/prepare" do
    case MinhaRua.prepare(conn.body_params) do
      {:ok, draft} -> json(conn, 200, draft)
      {:error, errors} -> json(conn, 422, %{errors: errors})
    end
  end

  get "/api/street-reports/recent" do
    case MinhaRua.latest() do
      {:ok, reports} -> json(conn, 200, reports)
      {:error, _} -> json(conn, 503, %{error: "Consulta oficial temporariamente indisponível."})
    end
  end

  post "/api/siga/queues/compare" do
    case Siga.compare(conn.body_params) do
      {:ok, queues} -> json(conn, 200, queues)
      {:error, errors} -> json(conn, 422, %{errors: errors})
    end
  end

  post "/api/financas/ebalcao/prepare" do
    case Financas.prepare_ebalcao(conn.body_params) do
      {:ok, draft} -> json(conn, 200, draft)
      {:error, errors} -> json(conn, 422, %{errors: errors})
    end
  end

  post "/mcp" do
    handle_mcp(conn, &MCP.handle/1)
  end

  post "/mcp/public" do
    handle_mcp(conn, &MCP.public_handle/1)
  end

  defp handle_mcp(conn, handler) do
    origin = get_req_header(conn, "origin") |> List.first()

    allowed =
      System.get_env(
        "MCP_ALLOWED_ORIGINS",
        "http://localhost:4000,https://ecidadao.pt,https://chatgpt.com,https://claude.ai,https://claude.com"
      )
      |> String.split(",", trim: true)

    accept = get_req_header(conn, "accept") |> Enum.join(",")

    cond do
      origin != nil and origin not in allowed ->
        send_resp(conn, 403, "Origin recusada")

      not String.contains?(accept, "application/json") ->
        send_resp(conn, 406, "Aceite application/json")

      true ->
        case handler.(conn.body_params) do
          :accepted -> send_resp(conn, 202, "")
          {:reply, payload} -> json(conn, 200, payload)
        end
    end
  end

  get "/mcp" do
    send_resp(conn, 405, "SSE não suportado neste endpoint")
  end

  get "/mcp/public" do
    send_resp(conn, 405, "SSE não suportado neste endpoint")
  end

  match _ do
    send_resp(conn, 404, "Não encontrado")
  end

  defp json(conn, status, value) do
    conn
    |> put_resp_content_type("application/json", "utf-8")
    |> put_resp_header("cache-control", "no-store")
    |> send_resp(status, Jason.encode!(value))
  end
end
