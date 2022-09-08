# Kadena

Elixir library to interact with the Kadena blockchain.

## Installation

Add `kadena` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kadena, "~> 0.1.0"}
  ]
end
```

## Configuration
```elixir
config :kadena, network: :test # Default is `:test`. To use the public network, set it to `:public`

```

The default HTTP Client is `:hackney`. Options to `:hackney` can be passed through configuration params.
```elixir
config :kadena, hackney_opts: [{:connect_timeout, 1000}, {:recv_timeout, 5000}]
```

## Changelog

Features and bug fixes are listed in the [CHANGELOG][changelog] file.

## Code of conduct

We welcome everyone to contribute. Make sure you have read the [CODE_OF_CONDUCT][coc] before.

## Contributing

For information on how to contribute, please refer to our [CONTRIBUTING][contributing] guide.

## License

This library is licensed under an MIT license. See [LICENSE][license] for details.

## Acknowledgements

Made with 💙 by [kommitters Open Source](https://kommit.co)

[license]: https://github.com/kommitters/kadena/blob/main/LICENSE
[coc]: https://github.com/kommitters/kadena/blob/main/CODE_OF_CONDUCT.md
[changelog]: https://github.com/kommitters/kadena/blob/main/CHANGELOG.md
[contributing]: https://github.com/kommitters/kadena/blob/main/CONTRIBUTING.md
