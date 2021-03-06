# ex_verify_origin

[![Build Status](https://img.shields.io/github/workflow/status/webstronauts/ex_verify_origin/test.svg?style=flat-square)](https://github.com/webstronauts/ex_verify_origin/actions?query=workflow%3Atest)
[![Hex.pm](https://img.shields.io/hexpm/v/ex_verify_origin.svg?style=flat-square)](https://hex.pm/packages/ex_verify_origin)

A Plug adapter to protect from CSRF attacks by verifying the `Origin` header.

<a href="https://webstronauts.com/">
  <img src="https://webstronauts.com/badges/sponsored-by-webstronauts.svg" alt="Sponsored by The Webstronauts" width="200" height="65">
</a>

## Installation

To use VerifyOrigin, you can add it to your application's dependencies.

```elixir
def deps do
  [
    {:ex_verify_origin, "~> 2.0.0"}
  ]
end
```

## Usage

You can use the plug within your pipeline.

```elixir
defmodule MyApp.Endpoint do
  plug Logger
  plug VerifyOrigin
  plug MyApp.Router
end
```

To find out more, head to the [online documentation]([https://hexdocs.pm/ex_verify_origin).

## Changelog

Please see [CHANGELOG](CHANGELOG.md) for more information on what has changed recently.

## Contributing

Clone the repository and run `mix test`. To generate docs, run `mix docs`.

## Credits

- [Robin van der Vleuten](https://github.com/robinvdvleuten)
- [All Contributors](../../contributors)

## License

The MIT License (MIT). Please see [License File](LICENSE) for more information.
