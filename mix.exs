defmodule ChessLogic.MixProject do
  use Mix.Project

  def project do
    [
      app: :chess_logic,
      version: "0.2.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      # erlc_paths: ["src"],
      dialyzer: [
        plt_add_deps: :transitive,
        ignore_warnings: "dialyzer.ignore-warnings"
      ],
      description: description(),
      package: package(),
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

      # Because hex does not allow non hex dependencies, include chessfold src files in src.
      # {:chessfold, github: "fcardinaux/chessfold", app: false},

      # Development
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.18.3", only: :dev, runtime: false},
      {:credo, "~> 0.10.0", only: [:dev], runtime: false}
    ]
  end
  
  defp description do
    """
    Elixir struct for playing the game of chess.
    """
  end
  
  defp package do
    # These are the default files included in the package
    [
      name: :chess_logic,
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["koko.le.gorille"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/kokolegorille/chess_logic"}
    ]
  end
end
