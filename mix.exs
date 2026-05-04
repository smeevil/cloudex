defmodule Cloudex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cloudex,
      version: "1.4.1",
      description: """
        A library that helps with uploading image files and urls to cloudinary.
        Also provides a helper to generate transformations and cloudinary urls pointing to your images
      """,
      package: package(),
      elixir: "~> 1.11",
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
      test_coverage: [
        tool: ExCoveralls
      ]
    ]
  end

  def cli do
    [
      preferred_envs: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
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
      {:credo, "~> 1.7", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:earmark, "> 0.0.0", only: :dev},
      {:ex_doc, "> 0.0.0", only: :dev},
      {:excoveralls, "> 0.0.0", only: :test},
      {:exvcr, "~> 0.17", only: :test},
      {:httpoison, "~> 2.3"},
      # Transitive ssl_verify_fun < 1.1.7 fails to compile on OTP 26+ (public_key records).
      {:ssl_verify_fun, "~> 1.1.7", override: true},
      {:mix_test_watch, "~> 1.4", only: :dev},
      {:jason, "~> 1.0", optional: true}
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
