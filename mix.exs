defmodule LivePremier.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_premier,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7"},
      {:ecto, "~> 3.11"},
      {:ex_doc, "~> 0.34.0", only: [:dev]},
      {:plug, "~> 1.0", only: [:test]},
      {:req, "~> 0.5"}
    ]
  end
end
