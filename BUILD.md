# Building the project

## Create project

```bash
$ mix new chess_logic
$ cd chess_logic
```

```bash
$ git init
$ git add .
$ git cmmit -m "Initial commit"
```

## Chessfold erlang dependencies

This application includes Erlang dependencies without app file. To include chessfold...

Update mix.exs

      erlc_paths: ["deps/chessfold/erl"],
      
      {:chessfold, github: "fcardinaux/chessfold", app: false},

## Add development tools

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

## Excluding chessfold from dialyxir

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

## Add logic and tests

See corresponding files