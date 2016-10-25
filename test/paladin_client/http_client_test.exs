defmodule Paladin.HTTPClientTest do
  use ExUnit.Case, async: true
  alias PaladinClient.HTTPClient, as: Client

  setup do
    bypass = Bypass.open

    new_config = :paladin_client
    |> Application.get_env(PaladinClient)
    |> Keyword.merge(url: "http://localhost:#{bypass.port}")

    :ok = Application.put_env(
      :paladin_client,
      PaladinClient,
      new_config
    )

    {:ok, bypass: bypass}
  end

  test "access_token when all goes well", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/authorize" == conn.request_path
      assert "POST" == conn.method

      {:ok, json, conn} = Plug.Conn.read_body(conn)
      params = Poison.decode!(json)

      assert params["grant_type"] == "urn:ietf:params:oauth:grant-type:sam12-bearer"
      assert params["assertion"] == "request_token"
      assert params["client_id"] == PaladinClient.client_id

      conn
      |> Plug.Conn.resp(200, Poison.encode!(%{token: "response_token"}))
      |> Plug.Conn.put_resp_header("X-Expiry", "500")
    end

    {:ok, token, exp} = Client.access_token("request_token")
    assert token == "response_token"
    assert exp == 500
  end

  test "access_token when receiving errors", %{bypass: bypass} do
    resp = %{
      "error" => "bad_juju",
      "error_description" => "really bad juju dude",
    }

    Bypass.expect bypass, fn conn ->
      conn
      |> Plug.Conn.resp(401, Poison.encode!(resp))
      |> Plug.Conn.put_resp_header("X-Expiry", "500")
    end

    {:error, reason} = Client.access_token("request_token")
    assert reason == "bad_juju"
  end

  test "access_token when a server error occurs", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      conn
      |> Plug.Conn.resp(502, Poison.encode!(%{whatever: "bad things"}))
    end
    {:error, reason} = Client.access_token("request_token")
    assert reason == :unknown_error
  end
end
