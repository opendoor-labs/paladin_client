defmodule PaladinClient.Test.Guardian do
  use Guardian, otp_app: :paladin_client

  def subject_for_token(thing, _claims), do: {:ok, thing}
  def resource_from_claims(%{"sub" => thing}), do: {:ok, thing}
end
