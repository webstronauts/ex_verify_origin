defmodule VerifyOriginTest do
  use ExUnit.Case, async: true
  use Plug.Test

  def url(), do: "https://example.com"
  def origin(), do: "https://example.com"

  def build_conn_for_path(path, method \\ :get) do
    conn(method, path)
    |> put_private(:phoenix_endpoint, __MODULE__)
    |> put_private(:phoenix_router, __MODULE__)
  end

  test "allows same-origin request for safe requests" do
    conn =
      build_conn_for_path("/foo")
      |> put_req_header("origin", origin())
      |> VerifyOrigin.call(VerifyOrigin.init())

    refute conn.halted
  end

  test "allows same-origin requests for unsafe requests" do
    conn =
      build_conn_for_path("/foo", :post)
      |> put_req_header("origin", origin())
      |> VerifyOrigin.call(VerifyOrigin.init())

    refute conn.halted
  end

  test "halts cross-origin requests for safe requests" do
    conn =
      build_conn_for_path("/foo")
      |> put_req_header("origin", "https://evil.com")
      |> VerifyOrigin.call(VerifyOrigin.init())

    assert conn.halted
  end

  test "halts cross-origin requests for unsafe requests" do
    conn =
      build_conn_for_path("/foo")
      |> put_req_header("origin", "https://evil.com")
      |> VerifyOrigin.call(VerifyOrigin.init())

    assert conn.halted
  end

  test "allows request for safe requests without origin" do
    conn =
      build_conn_for_path("/foo")
      |> VerifyOrigin.call(VerifyOrigin.init())

    refute conn.halted
  end

  test "allows request for safe requests without origin when not strict" do
    conn =
      build_conn_for_path("/foo")
      |> VerifyOrigin.call(VerifyOrigin.init(strict: false))

    refute conn.halted
  end

  test "halts request for safe requests without origin when safe not allowed" do
    conn =
      build_conn_for_path("/foo")
      |> VerifyOrigin.call(VerifyOrigin.init(allow_safe: false))

    assert conn.halted
  end

  test "falls back to referer for safe requests without origin" do
    conn =
      build_conn_for_path("/foo")
      |> put_req_header("referer", origin())
      |> VerifyOrigin.call(VerifyOrigin.init(fallback_to_referer: true))

    refute conn.halted
  end

  test "halts request for unsafe requests without origin" do
    conn =
      build_conn_for_path("/foo", :post)
      |> VerifyOrigin.call(VerifyOrigin.init())

    assert conn.halted
  end

  test "allows request for unsafe requests without origin when not strict" do
    conn =
      build_conn_for_path("/foo", :post)
      |> VerifyOrigin.call(VerifyOrigin.init(strict: false))

    refute conn.halted
  end

  test "falls back to referer for unsafe requests without origin" do
    conn =
      build_conn_for_path("/foo", :post)
      |> put_req_header("referer", origin())
      |> VerifyOrigin.call(VerifyOrigin.init(fallback_to_referer: true))

    refute conn.halted
  end
end
