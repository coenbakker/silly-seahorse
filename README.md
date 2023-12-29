# SillySeahorse

Create random usernames like "silly_seahorse" and "anxious-turtle".

Currently, only supports lower case letters. However, you can choose
a custom delimiter. By default "_" us used as delimiter.

## Installation

Add `silly_seahorse` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:silly_seahorse, "~> 0.1"}
  ]
end
```

## Usage

### `generate_random/0` and `generate_random/1`

```elixir
generate_random()
=> "silly_seahorse"
generate_random(delimiter: "-")
=> "anxious-turtle"
```

## License

MIT
