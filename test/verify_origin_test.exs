defmodule VerifyOriginTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias VerifyOrigin.UnverifiedOriginError

  def url(), do: "http://www.example.com"
  def origin(), do: "http://www.example.com"

  def call(conn), do: call(conn, origin())

  def call(conn, plug_opts) when is_list(plug_opts), do: call(conn, origin(), plug_opts)

  def call(conn, origin, plug_opts \\ [])
  def call(conn, nil, plug_opts), do: call_plug_with_opts(conn, plug_opts)

  def call(conn, origin, plug_opts) do
    conn
    |> put_req_header("origin", origin)
    |> call_plug_with_opts(plug_opts)
  end

  defp call_plug_with_opts(conn, plug_opts) do
    conn
    |> put_private(:phoenix_endpoint, __MODULE__)
    |> put_private(:phoenix_router, __MODULE__)
    |> VerifyOrigin.call(VerifyOrigin.init(plug_opts))
  end

  test "allows same-origin request for safe requests" do
    conn = call(conn(:get, "/foo"))
    refute conn.halted
  end

  test "allows same-origin requests for unsafe requests" do
    conn = call(conn(:post, "/foo"))
    refute conn.halted
  end

  test "raise error for cross-origin requests for safe requests" do
    assert_raise UnverifiedOriginError, fn ->
      call(conn(:get, "/foo"), "https://evil.com")
    end
  end

  test "raise error for cross-origin requests for unsafe requests" do
    assert_raise UnverifiedOriginError, fn ->
      call(conn(:get, "/foo"), "https://evil.com")
    end
  end

  test "allows request for safe requests without origin" do
    conn = call(conn(:get, "/foo"))
    refute conn.halted
  end

  test "allows request for safe requests without origin when not strict" do
    conn = call(conn(:get, "/foo"), strict: false)
    refute conn.halted
  end

  test "raise error for request for safe requests without origin when safe not allowed" do
    assert_raise UnverifiedOriginError, fn ->
      call(conn(:get, "/foo"), nil, allow_safe: false)
    end
  end

  test "falls back to referer for safe requests without origin" do
    conn =
      conn(:get, "/foo")
      |> put_req_header("referer", origin())
      |> call(nil, fallback_to_referer: true)

    refute conn.halted
  end

  test "raise error for request for unsafe requests without origin" do
    assert_raise UnverifiedOriginError, fn ->
      call(conn(:post, "/foo"), nil)
    end
  end

  test "allows request for unsafe requests without origin when not strict" do
    conn = call(conn(:post, "/foo"), nil, strict: false)
    refute conn.halted
  end

  test "falls back to referer for unsafe requests without origin" do
    conn =
      conn(:post, "/foo")
      |> put_req_header("referer", origin())
      |> call(nil, fallback_to_referer: true)

    refute conn.halted
  end

  test "is skipped when plug_skip_verify_origin is true" do
    conn =
      conn(:post, "/foo")
      |> put_private(:plug_skip_verify_origin, true)
      |> call()

    refute conn.halted

    conn =
      conn(:post, "/foo")
      |> put_private(:plug_skip_verify_origin, true)
      |> call("https://evil.com")

    refute conn.halted

    conn =
      conn(:post, "/foo")
      |> put_private(:plug_skip_verify_origin, true)
      |> call(nil)

    refute conn.halted
  end
end
