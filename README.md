# DistributedTest

Run your Elixir tests in a distributed environment!

## Usage

Use the default number of nodes (1 master + 4 slaves)
```
mix test.distributed
```

Use a specific number of nodes (1 master + n slaves).  Note the master is
not included in the count.
```
mix test.distributed --count 7
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `distributed_test` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:distributed_test, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/distributed_test](https://hexdocs.pm/distributed_test).
