defmodule PaladinClient.Token.Guardian04 do
  require PaladinClient.Token
  @behaviour PaladinClient.Token

  defdelegate peek_claims(token), to: Guardian, as: :peek

  def paladin_app_id do
    Guardian.issuer()
  end

  def sub_from_resource(resource) do
    Guardian.serializer.for_token(resource)
  end

  def encode_and_sign(sub, token_type, claims, ttl) do
    claims =
      claims
      |> Map.put(:ttl, ttl)

    Guardian.encode_and_sign(sub, token_type, claims)
  end
end
