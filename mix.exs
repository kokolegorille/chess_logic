defmodule ChessLogic.MixProject do
  use Mix.Project

  def project do
    [
      app: :chess_logic,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      # ADD THIS OPTION
      erlc_paths: ["deps/chessfold/erl", "src"],
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings"
      ],
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},

      {:chessfold, github: "fcardinaux/chessfold", app: false},

      # Development
      {:dialyxir, "~> 0.5.1", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.18.3", only: :dev, runtime: false},
      {:credo, "~> 0.8.10", only: [:dev], runtime: false}
    ]
  end
end
