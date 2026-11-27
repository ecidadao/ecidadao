import Config

config :ecidadao, EcidadaoWeb.Endpoint,
  http: [
    ip: {127, 0, 0, 1},
    port: String.to_integer(System.get_env("ECIDADAO_HTTP_PORT", "4000"))
  ]
