defmodule PaladinClient.Token.Guardian10 do
  require PaladinClient.Token
  @behaviour PaladinClient.Token

  def peek_claims(token) do
    result = guardian_module().peek(token)
    case result do
      %{claims: %{} = claims} -> claims
      _ -> %{}
    end
  end

  def paladin_app_id do
    guardian_module().config(:issuer)
  end

  def sub_from_resource(resource) do
    guardian_module().subject_for_token(resource, %{})
  end

  def encode_and_sign(sub, token_type, claims, ttl) do
    guardian_module().encode_and_sign(sub, claims, token_type: token_type, ttl: ttl)
  end

  defp guardian_module do
    Application.get_env(:paladin_client, PaladinClient.Token)[:guardian_module]
  end
end
