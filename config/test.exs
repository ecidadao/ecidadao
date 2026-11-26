import Config

config :ecidadao, Ecidadao.Repo,
  database: ":memory:",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 1

config :ecidadao, EcidadaoWeb.Endpoint, server: false
