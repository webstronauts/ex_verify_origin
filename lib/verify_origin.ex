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
    call(conn, %{config | origin: get_origin_from_conn(conn)})
  end

  def call(conn, config) do
    origin =
      conn
      |> get_req_header("origin")
      |> fallback_to_referer(conn, config)
      |> List.first()

    if verified_origin?(conn, origin, config) do
      conn
    else
      conn
      |> send_resp(:bad_request, "")
      |> halt()
    end
  end

  defp verified_origin?(_conn, nil, %{strict: false}),
    do: true

  defp verified_origin?(%{method: method}, nil, %{allow_safe: true}) when method in @safe_methods,
    do: true

  defp verified_origin?(_conn, origin, %{origin: allowed_origin}), do: origin == allowed_origin

  defp get_origin_from_conn(conn) do
    conn
    |> Phoenix.Controller.current_url()
    |> URI.parse()
    |> Map.put(:path, nil)
    |> to_string()
  end

  defp fallback_to_referer([], conn, %{fallback_to_referer: true}) do
    get_req_header(conn, "referer")
  end

  defp fallback_to_referer(origin, _conn, _opts), do: origin
end
