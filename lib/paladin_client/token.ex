defmodule PaladinClient.Token do
  @type token :: String.t
  @type app_id :: String.t
  @type subject :: String.t
  @type resource :: any
  @type claims :: map
  @type token_type :: atom
  @type ttl ::
          {pos_integer, :second}
          | {pos_integer, :seconds}
          | {pos_integer, :minute}
          | {pos_integer, :minutes}
          | {pos_integer, :day}
          | {pos_integer, :days}
          | {pos_integer, :week}
          | {pos_integer, :weeks}

  @doc "Peek at the claims without validating or verifying the token"
  @callback peek_claims(token) :: claims

  @doc "Get the paladin application id"
  @callback paladin_app_id() :: app_id

  @doc "Given a resource, provide the subject for the token"
  @callback sub_from_resource(resource) :: subject

  @doc "Encode and sign the token ready for transport"
  @callback encode_and_sign(subject, token_type, claims, ttl) ::
      {:ok, token, claims} :: {:error, term}

  def adapter do
    Application.get_env(:paladin_client, :token_adapter)
  end
end
