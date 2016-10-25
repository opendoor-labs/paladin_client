defmodule PaladinClient.InMemory do
  @moduledoc """
  An in memory adapter for PaladinClient testing
  """
  @behaviour PaladinClient

  def access_token(_assertion_token) do
    token = "assertion_token:#{System.os_time(:nanoseconds)}"
    {:ok, token, System.os_time(:seconds) + System.convert_time_unit(5, :seconds, :seconds)}
  end
end
