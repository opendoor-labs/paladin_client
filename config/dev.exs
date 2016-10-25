use Mix.Config

config :guardian, Guardian,
  serializer: PaladinClient.Test.GuardianSerializer,
  issuer: "paladin_client_dev",
  secret_key: "dev"

config :paladin_client, PaladinClient,
  anon_user: fn -> "anon_me" end,
  adapter: PaladinClient.HttpClient,
  url: "http://localhost:4000",
  apps: [
    one: "one-app-id",
    two: "two-app-id",
  ]
