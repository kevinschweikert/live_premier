defmodule LivePremier.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_premier,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "LivePremier",
      source_url: "https://github.com/kevinschweikert/live_premier",
      homepage_url: "https://github.com/kevinschweikert/live_premier",
      docs: [
        authors: ["Kevin Schweikert"],
        main: LivePremier,
        groups_for_modules: [
          "System commands": [
            LivePremier.System,
            LivePremier.System.Info,
            LivePremier.System.Version
          ],
          "Screen commands": [
            LivePremier.Screen,
            LivePremier.Screen.Info,
            LivePremier.Screen.LayerInfo,
            LivePremier.Screen.LayerStatus
          ]
        ],
        groups_for_docs: [System: &(&1[:module] == :system), Screen: &(&1[:module] == :screen)],
        nest_modules_by_prefix: [
          LivePremier.System,
          LivePremier.System.Info,
          LivePremier.System.Version,
          LivePremier.Screen,
          LivePremier.Screen.Info,
          LivePremier.Screen.LayerInfo,
          LivePremier.Screen.LayerStatus
        ]
      ]
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
