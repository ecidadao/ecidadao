defmodule EcidadaoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :ecidadao

  plug(Plug.Static,
    at: "/marca",
    from: {:ecidadao, "priv/static/brand"},
    only:
      ~w(ecidadao-logo.svg ecidadao-logo.png ecidadao-simbolo.svg ecidadao-simbolo.png ecidadao-github.svg ecidadao-github.png ecidadao-identidade.zip README.txt)
  )

  plug(Plug.RequestId)

  plug(Plug.Static,
    at: "/map-assets",
    from: {:ecidadao, "priv/static/map"},
    only: ~w(leaflet.js leaflet.css municipal-map.js municipal-map.css images LEAFLET-LICENSE.txt)
  )

  plug(Plug.Telemetry, event_prefix: [:ecidadao, :endpoint])

  plug(Plug.Static,
    at: "/imagens",
    from: {:ecidadao, "priv/static/images"},
    only: ~w(siga-passo.png siga-resultado.png financas-passo.png financas-rascunho.png)
  )

  plug(Plug.Static,
    at: "/downloads",
    from: {:ecidadao, "priv/static/downloads"},
    only: ~w(ecidadao-plugin-0.3.1.zip)
  )

  plug(Plug.Static,
    at: "/review",
    from: {:ecidadao, "priv/static/review"},
    only: ~w(ecidadao-0.3.1-7aaa4cd838b2e9c17e6fc6fb5f6f9705.mp4)
  )

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["application/json"],
    json_decoder: Jason,
    length: 64_000,
    read_length: 64_000
  )

  plug(EcidadaoWeb.Router)
end
