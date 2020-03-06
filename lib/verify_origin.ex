defmodule VerifyOrigin do
  @moduledoc """
  A Plug adapter to protect from CSRF attacks by verifying the `Origin` header.

  ## Options
    * `:origin` - The origin of the server - requests from this origin will always proceed. Defaults to the default hostname configured for your application's endpoint.
    * `:strict` - Whether to reject requests that lack an Origin header. Defaults to `true`.
    * `:allow_safe` - Whether to enforce the strict mode for safe requests (GET, HEAD). Defaults to `true`.
    * `:fallback_to_referer` - If the Origin header is missing, fill it with the origin part of the Referer. Defaults to `false`.
  """

  import Plug.Conn

  @safe_methods ["GET", "HEAD"]

  def init(opts \\ []) do
    origin = Keyword.get(opts, :origin)
    strict = Keyword.get(opts, :strict, true)
    allow_safe = Keyword.get(opts, :allow_safe, true)
    fallback_to_referer = Keyword.get(opts, :fallback_to_referer, false)

    %{
      origin: origin,
      strict: strict,
      allow_safe: allow_safe,
      fallback_to_referer: fallback_to_referer
    }
  end

  def call(conn, config = %{origin: nil}) do
    current_origin =
      conn
      |> Phoenix.Controller.current_url()
      |> URI.parse()
      |> Map.put(:path, nil)
      |> to_string()

    call(conn, %{config | origin: current_origin})
  end

  def call(conn, config) do
    %{origin: allowed_origin, strict: strict, allow_safe: allow_safe} = config

    origin =
      conn
      |> get_req_header("origin")
      |> fallback_to_referrer(conn, config)
      |> List.first()

    cond do
      origin == nil && !strict ->
        conn

      origin == nil && allow_safe && conn.method in @safe_methods ->
        conn

      origin == allowed_origin ->
        conn

      true ->
        conn
        |> send_resp(403, "")
        |> halt()
    end
  end

  defp fallback_to_referrer([], conn, %{fallback_to_referer: true}) do
    get_req_header(conn, "referer")
  end

  defp fallback_to_referrer(origin, conn, opts), do: origin
end
