defmodule Cloudex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cloudex,
      version: "0.1.8",
      description: "A library that helps with uploading image files and urls to cloudinary. Also provides an helper to generate transformations and cloudinary urls pointing to your images",
      package: package,
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      test_coverage: [tool: ExCoveralls]

     ]
  end

  def application do
    [
      applications: [:logger, :httpoison, :tzdata, :timex],
      mod: {Cloudex.Settings, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.9.0"},
      {:poison, "~> 2.2.0"},
      {:timex, "~> 3.0.6"},
      {:tzdata, "~> 0.5.8"},
      {:credo, "~> 0.4.8", only: :dev},
      {:earmark, "~> 1.0.1", only: :dev},
      {:ex_doc, "~> 0.13.0", only: :dev},
      {:mix_test_watch, "~> 0.2.6", only: :dev},
      {:excoveralls, "~> 0.5.5", only: :test},
    ]
  end

  defp package do
    [
      maintainers: ["Gerard de Brieder"],
      licenses: ["WTFPL"],
      files: ["lib", "priv", "mix.exs", "README*", "LICENSE*", "CHANGELOG*"],
      links: %{
        "GitHub" => "https://github.com/smeevil/cloudex",
        "Docs"   => "http://smeevil.github.io/cloudex/"
      }
    ]
  end
end
