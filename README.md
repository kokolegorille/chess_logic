# ChessLogic

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `chess_logic` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:chess_logic, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/chess_logic](https://hexdocs.pm/chess_logic).

## Description

Functional Chess validator written in Elixir. Depends on fcardinaux/chessfold.

### Create project

```bash
$ mix new chess_logic
$ cd chess_logic
```

```bash
$ git init
$ git add .
$ git cmmit -m "Initial commit"
```

### Chessfold erlang dependencies

This application includes Erlang dependencies without app file. To include chessfold...

Update mix.exs

erlc_paths: ["deps/chessfold/erl"],

{:chessfold, github: "fcardinaux/chessfold", app: false},

### Add development tools

Update mix.exs

      {:dialyxir, "~> 0.5.1", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.18.3", only: :dev, runtime: false},
      {:credo, "~> 0.8.10", only: [:dev], runtime: false}

```bash
$ mix deps.get
```

This will allow to use

```bash
$ mix credo
$ mix dialyzer
```

### Excluding chessfold from dialyxir

Update mix.exs

      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings",
      ],

Add dialyzer.ignore-warnings

```elixir
Unknown function chessfold
Guard test RowId::0
The variable _ can never match since previous clauses completely covered the type
```

This will remove warnings on chessfold...

