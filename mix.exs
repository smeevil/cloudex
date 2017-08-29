defmodule Cloudex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cloudex,
      version: "0.1.20",
      description: "A library that helps with uploading image files and urls to cloudinary. Also provides an helper to generate transformations and cloudinary urls pointing to your images",
      package: package(),
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      test_coverage: [tool: ExCoveralls]

     ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Cloudex.Settings, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.11.0"},
      {:poison, "~> 3.1.0"},
      {:timex, "~> 3.1.7"},
      {:tzdata, "~> 0.5.11"},
      {:credo, "> 0.0.0", only: :dev},
      {:earmark, "> 0.0.0", only: :dev},
      {:ex_doc, "> 0.0.0", only: :dev},
      {:mix_test_watch, "> 0.0.0", only: :dev},
      {:excoveralls, "> 0.0.0", only: :test},
    ]
  end

  defp package do
    [
      maintainers: ["Gerard de Brieder"],
      licenses: ["WTFPL"],
      files: ["lib", "mix.exs", "README*", "LICENSE*", "CHANGELOG*"],
      links: %{
        "GitHub" => "https://github.com/smeevil/cloudex",
        "Docs"   => "http://smeevil.github.io/cloudex/"
      }
    ]
  end
end
