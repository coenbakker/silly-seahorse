# SillySeahorse

Create random usernames like "silly_seahorse" and "anxious-turtle".

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
=> "silly-seahorse"
generate_random(delimiter: "_")
=> "very_anxious_turtle"
generate_random(allow_adverb: false)
=> "happy-hippopotamus"
```

## License

MIT
