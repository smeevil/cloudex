defmodule Cloudex.Mixfile do
  use Mix.Project

  def project do
    [app: :cloudex,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      applications: [:logger, :httpoison, :tzdata],
      mod: {Cloudex.Settings, []}
    ]
  end

  defp deps do
    [
      {:mix_test_watch, "~> 0.2.4"},
      {:httpoison, "~> 0.8.0"},
      {:poison, "~> 1.5.0"},
      {:timex, "~> 0.19.5"},
      {:tzdata, "== 0.1.8", override: true}, #hack for timex to work with escript
      {:credo, "~> 0.1.10", only: :dev},
      {:earmark, "> 0.0.0", only: :dev},
      {:ex_doc, "> 0.0.0", only: :dev}
    ]
  end
end
