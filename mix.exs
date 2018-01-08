defmodule Cloudex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cloudex,
      version: "1.1.0",
      description: "A library that helps with uploading image files and urls to cloudinary. Also provides an helper to generate transformations and cloudinary urls pointing to your images",
      package: package(),
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_deps: true,
        ignore_warnings: "dialyzer.ignore-warnings",
        flags: [
          :error_handling,
          :race_conditions,
          :unknown,
          :unmatched_returns,
        ],
      ],

      preferred_cli_env: [
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "vcr": :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ],
      test_coverage: [
        tool: ExCoveralls
      ],
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
      {:credo, "> 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "> 0.0.0", only: :dev, runtime: false},
      {:earmark, "> 0.0.0", only: :dev},
      {:ex_doc, "> 0.0.0", only: :dev},
      {:excoveralls, "> 0.0.0", only: :test},
      {:exvcr, ">= 0.0.0", [only: :test]},
      {:httpoison, "~> 0.13.0"},
      {:mix_test_watch, "> 0.0.0", only: :dev},
      {:poison, "~> 3.1.0"},
      {:timex, "~> 3.1.7"},
      {:tzdata, "~> 0.5.11"},
    ]
  end

  defp package do
    [
      maintainers: ["Gerard de Brieder"],
      licenses: ["WTFPL"],
      files: ["lib", "mix.exs", "README*", "LICENSE*", "CHANGELOG*"],
      links: %{
        "GitHub" => "https://github.com/smeevil/cloudex",
        "Docs" => "http://smeevil.github.io/cloudex/"
      }
    ]
  end
end
