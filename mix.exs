defmodule Ecidadao.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecidadao,
      version: "0.3.4",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto, :inets, :ssl],
      mod: {Ecidadao.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.8"},
      {:bandit, "~> 1.8"},
      {:jason, "~> 1.4"}
    ]
  end
end
