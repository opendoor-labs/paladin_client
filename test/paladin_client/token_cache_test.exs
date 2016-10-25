defmodule Paladin.TokenCacheTest do
  use ExUnit.Case, async: true
  alias PaladinClient.TokenCache, as: Cache

  test "find a token based on a key that exists" do
    true = Cache.store!({"key", 1}, "value")
    result = Cache.find({"key", 1})
    assert result == {:ok, "value"}
  end

  test "runs a function if it is not found" do
    result = Cache.find(:not_a_key, fn -> :not_found end)
    assert result == :not_found
  end

  test "clears a key" do
    true = Cache.store!({"key", 2}, "two")
    result = Cache.find({"key", 2})
    assert result == {:ok, "two"}
    assert :ok == Cache.clear({"key", 2})
    result = Cache.find({"key", 2}, fn -> :not_found end)
    assert result == :not_found
  end

  test "expires an entry" do
    true = Cache.store!({"key", 3}, "three", System.os_time(:seconds) + 1)
    Process.sleep(1010)
    result = Cache.find({"key", 2}, fn -> :not_found end)
    assert result == :not_found
  end
end
