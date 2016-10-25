defmodule PaladinClient.TokenCache do
  @moduledoc """
  Provides a read through cache for dealing with Paladin tokens.
  Tokens are cached for each access token and application id
  """
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    :ets.new(__MODULE__, [:set, :public, :named_table, read_concurrency: true])
    {:ok,state}
  end

  # We need the original token + the app id to be the key
  def find(key, fun \\ fn -> nil end) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, token, _}] -> {:ok, token}
      _ -> fun.()
    end
  end

  def store!(key, token, exp \\ :infinity) do
    GenServer.call(__MODULE__, {:store, {key, token, exp}})
  end

  def store(key, token, exp \\ :infinity) do
    GenServer.cast(__MODULE__, {:store, {key, token, exp}})
  end

  def clear(key) do
    GenServer.call(__MODULE__, {:clear, key})
  end

  defp clear_key(key) do
    :ets.delete(__MODULE__, key)
  end

  # Callbacks

  def handle_call({:clear, key}, _from, state) do
    clear_key(key)
    {:reply, :ok, state}
  end

  def handle_call({:store, data}, _from, state) do
    {:reply, do_store(data), state}
  end

  def handle_cast({:store, data}, state) do
    do_store(data)
    {:noreply,state}
  end

  def handle_info({:expire, key, expired_token}, state) do
    # If the key value has changed lets not clear it
    # This clear is only for the original token that was in there
    case :ets.lookup(__MODULE__, key) do
      [{^key, ^expired_token, _}] -> clear_key(key)
      _ -> :noop
    end

    {:noreply, state}
  end

  def handle_info(msg, state), do: super(msg, state)

  defp do_store({key, val}), do: do_store({key, val, :infinity})
  defp do_store({key, val, exp} = data) do
    result = :ets.insert(__MODULE__, data)
    case exp do
      :infinity -> result
      nil -> result
      _ ->
        expire_in = (exp - System.os_time(:seconds)) * 1000
        :erlang.send_after(expire_in, self(), {:expire, key, val})
        result
    end
  end
end
