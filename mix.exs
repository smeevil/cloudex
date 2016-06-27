defmodule Cloudex.Mixfile do
  use Mix.Project

  def project do
    [app: :cloudex,
     version: "0.1.1",
     description: "A library that helps with uploading image files and urls to cloudinary. Also provides an helper to generate transformations and cloudinary urls pointing to your images",
     package: package,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
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
      {:timex, "~> 2.2"},
      {:tzdata, "> 0.0.0"},
      {:credo, "~> 0.4.5", only: :dev},
      {:earmark, "> 0.0.0", only: :dev},
      {:ex_doc, "> 0.0.0", only: :dev},
      {:mix_test_watch, "~> 0.2.4", only: :dev},
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
