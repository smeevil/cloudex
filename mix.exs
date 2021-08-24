defmodule Cloudex.Mixfile do
  use Mix.Project

  @source_url "https://github.com/smeevil/cloudex"
  @version "1.4.1"

  def project do
    [
      app: :cloudex,
      version: @version,
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
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
      {:ex_doc, "> 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "> 0.0.0", only: :test},
      {:exvcr, "~> 0.10", [only: :test]},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.0", optional: true},
      {:mix_test_watch, "> 0.0.0", only: :dev},
      {:timex, "~> 3.6"},
      {:tzdata, "~> 1.0"}
    ]
  end

  defp package do
    [
      description:
        "A library that helps with uploading image files and urls to cloudinary. " <>
          "Also provides a helper to generate transformations and cloudinary urls " <>
          "pointing to your images",
      maintainers: ["Gerard de Brieder"],
      licenses: ["WTFPL"],
      files: ["lib", "mix.exs", "README*", "LICENSE*", "CHANGELOG*"],
      links: %{
        "Changelog" => "https://hexdocs.pm/cloudex/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "LICENSE": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      formatters: ["html"]
    ]
  end
end
