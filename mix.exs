defmodule Cloudex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cloudex,
      version: "1.3.0",
      description: """
        A library that helps with uploading image files and urls to cloudinary.
        Also provides a helper to generate transformations and cloudinary urls pointing to your images
      """,
      package: package(),
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_deps: true,
        ignore_warnings: "dialyzer.ignore-warnings",
        flags: [
          :error_handling,
          :race_conditions,
          :unknown,
          :unmatched_returns
        ]
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ],
      test_coverage: [
        tool: ExCoveralls
      ]
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
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:earmark, "> 0.0.0", only: :dev},
      {:ex_doc, "> 0.0.0", only: :dev},
      {:excoveralls, "> 0.0.0", only: :test},
      {:exvcr, "~> 0.10.2", [only: :test]},
      {:httpoison, "~> 1.6"},
      {:mix_test_watch, "> 0.0.0", only: :dev},
      {:jason, "~> 1.0", optional: true},
      {:timex, "~> 3.6"},
      {:tzdata, "~> 1.0"}
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
