import Config

config :ecidadao, EcidadaoWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  server: true,
  secret_key_base: String.duplicate("local-development-only-", 4)

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
