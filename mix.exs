defmodule VerifyOrigin.MixProject do
  use Mix.Project

  @version "1.0.0"
  @description "Plug adapter to protect from CSRF attacks by verifying the `Origin` header."

  def project do
    [
      app: :ex_verify_origin,
      version: @version,
      elixir: "~> 1.9",
      deps: deps(),

      # Hex
      package: package(),
      description: @description,

      # Docs
      name: "VerifyOrigin",
      docs: [
        main: "VerifyOrigin",
        source_ref: "v#{@version}",
        source_url: "https://github.com/webstronauts/ex_verify_origin"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :plug]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.15", only: :dev},
      {:plug, "~> 1.8"}
    ]
  end

  defp package() do
    [
      maintainers: ["Robin van der Vleuten"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/webstronauts/ex_verify_origin"}
    ]
  end
end
