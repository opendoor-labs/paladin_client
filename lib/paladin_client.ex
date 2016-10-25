defmodule PaladinClient do
  @moduledoc """
  Provides helper functions for working with the Paladin service
  and a Behaviour for adapters
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [worker(PaladinClient.TokenCache, [])]
    opts = [strategy: :one_for_one, name: PaladinClient.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @type jwt :: String.t
  @type app_id :: atom | String.t
  @type assertion_token :: jwt
  @type expiry :: non_neg_integer
  @type reason :: atom | String.t

  @default_anon_user "anon"

  alias PaladinClient.TokenCache

  @callback access_token(assertion_token) :: {:ok, jwt, expiry} |
                                             {:error, reason}


  @spec from_existing_token(jwt, app_id, Map.t) :: {:ok, jwt} | {:error, reason}

  @doc """
  When you have an existing Guardian JWT you may use it to
  exchange via Paladin for a token of the application you wish to talk to
  """
  def from_existing_token(token, app_id, opts \\ %{}) do
    id = fetch_app_id(app_id)
    TokenCache.find({token, id}, fn ->
      case Guardian.decode_and_verify(token) do
        {:ok, claims} ->
          {:ok, user} = Guardian.serializer.from_token(claims["sub"])
          claims = Map.merge(claims, opts)
          {:ok, the_token} = new_assertion_token(id, user, claims)
          access_token!(the_token, token, id)

        error -> error
      end
    end)
  end

  @spec anon_token(jwt, Map.t) :: {:ok, token} :: {:error, term}
  @doc """
  When there is no existing token.
  This is useful for when there is no user you are acting on behalf of.
  Primarily system to system
  """
  def anon_token(app_id, claims \\ %{}) do
    user = anon_user
    id = fetch_app_id(app_id)
    TokenCache.find({user, id}, fn ->
      case new_assertion_token(app_id, user, claims) do
        {:ok, token} ->
          access_token!(token, user, id)
        error -> error
      end
    end)
  end

  @spec new_assertion_token(app_id, term, Map.t) :: {:ok, jwt} | {:error, term}
  @doc """
  Without an existing token, you may generate your own token
  to make use as an exchange for Paladin
  """
  def new_assertion_token(app_id, user, claims \\ %{}) do
    id = fetch_app_id(app_id)
    {:ok, sub} = Guardian.serializer.for_token(user)
    claims = claims
    |> Map.drop(["iat", "exp"])
    |> Map.put("aud", id)
    |> Map.put_new(:ttl, {1, :minute})

    result = Guardian.encode_and_sign(sub, :assertion, claims)

    case result do
      {:ok, jwt, _full_claims} -> {:ok, jwt}
      error -> error
    end
  end

  @doc """
  Fetch the paladin id from config via the name

  In your configuration you should add a KWList of name: id

     config :paladin_client, PaladinClient,
       apps: [
         app_one: "app-one-id",
         app_two: "app-two-id",
       ]

  PaladinClient.fetch_app_id(:app_one) == "app-one-id"
  """
  def fetch_app_id(app_id) when is_atom(app_id) do
    Application.get_env(:paladin_client, PaladinClient)[:apps][app_id]
  end

  def fetch_app_id(app_id), do: app_id

  @doc """
  When using Paladin, your issuer should be your application ID.
  """
  def client_id, do: Application.get_env(:guardian, Guardian)[:issuer]

  @doc """
  Fetch the url of Paladin in this environment
  """
  def endpoint, do: Application.get_env(:paladin_client, PaladinClient)[:url]

  @doc """
  Fetches the resource to use as an anonymous user when communicating system to system.
  Usually this would be "anon"
  """
  def anon_user, do: fetch_anon_user

  defp access_token!(the_token, original_token, app_id) do
    adapter = Application.get_env(:paladin_client, __MODULE__)[:adapter]
    case adapter.access_token(the_token) do
      {:ok, access_token, exp} ->
        TokenCache.store!({original_token, app_id}, access_token, exp)
        {:ok, access_token}
      error -> error
    end
  end

  defp fetch_anon_user do
    config = Application.get_env(:paladin_client, __MODULE__)
    fetch_anon_user(config && config[:anon_user])
  end

  defp fetch_anon_user(nil), do: @default_anon_user
  defp fetch_anon_user(false), do: @default_anon_user
  defp fetch_anon_user(f) when is_function(f), do: f.()
  defp fetch_anon_user(other), do: other
end
