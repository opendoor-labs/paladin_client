defmodule PaladinClientTest do
  use ExUnit.Case
  doctest PaladinClient

  alias PaladinClient, as: Client

  setup do
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign("the_user")
    {:ok, %{jwt: jwt}}
  end

  test "from_existing_token does a lookup then caches the result", %{jwt: jwt} do
    {:ok, new_token} = Client.from_existing_token(jwt, :one)
    result = Client.from_existing_token(jwt, :one)
    assert result == {:ok, new_token}
  end
end
