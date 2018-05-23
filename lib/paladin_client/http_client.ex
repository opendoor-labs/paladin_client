defmodule PaladinClient.HTTPClient do
  @moduledoc """
  Live client for interacting with Paladin
  """
  @behaviour PaladinClient

  @type jwt :: String.t

  use HTTPoison.Base
  require Logger

  @headers [
    {"Content-Type", "application/json"},
    {"Accept", "application/json"},
  ]

  @doc """
  Obtain an access_token from a previously generated assertion token (PaladinClient.assertion_token)
  """
  @spec access_token(jwt) :: {:ok, jwt, non_neg_integer} | {:error, String.t | atom}
  def access_token(assertion_token) do
    params = %{
      "grant_type" => "urn:ietf:params:oauth:grant-type:sam12-bearer",
      "assertion" => assertion_token,
      "client_id" => PaladinClient.client_id
    }

    case post("/authorize", params) do
      {:ok, %{status_code: status, body: body, headers: headers}} when status == 200 ->
        {:ok, body["token"], expiry_from_headers(headers)}

      {:ok, %{body: %{"error" => error}}} -> {:error, error}

      {:error, %{reason: reason} = response} ->
        Logger.warn("Could not obtain access token\n#{inspect(response)}")
        {:error, reason}

      err ->
        IO.inspect(err)
        {:error, :unknown_error}
    end
  end

  defp process_url(path), do: PaladinClient.endpoint <> path

  defp process_request_body(body) when is_map(body), do: Poison.encode!(body)
  defp process_request_body(body), do: body

  defp process_request_headers(nil), do: @headers
  defp process_request_headers(headers), do: headers ++ @headers

  defp process_response_body(nil), do: nil
  defp process_response_body(body), do: Poison.decode!(body)

  defp expiry_from_headers([{"X-Expiry", val} | _]) do
    {int, _} = Integer.parse(val)
    int
  end

  defp expiry_from_headers([_ | rest]), do: expiry_from_headers(rest)
  defp expiry_from_headers([]), do: nil
end
