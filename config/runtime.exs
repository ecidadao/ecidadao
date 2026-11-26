import Config

if config_env() == :prod do
  secret = System.fetch_env!("SECRET_KEY_BASE")
  port = String.to_integer(System.get_env("PORT", "4000"))

  config :ecidadao, EcidadaoWeb.Endpoint,
    http: [ip: {0, 0, 0, 0}, port: port],
    secret_key_base: secret
end
