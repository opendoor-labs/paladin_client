use Mix.Config

config :paladin_client, PaladinClient.Test.Guardian,
  issuer: "paladin_client_test",
  secret_key: "test"

config :paladin_client, token_adapter: PaladinClient.Token.Guardian10

config :paladin_client, PaladinClient,
  adapter: PaladinClient.InMemory,
  url: "http://localhost:4000",
  apps: [
    one: "one-app-id",
    two: "two-app-id",
  ]

config :paladin_client, PaladinClient.Token,
  guardian_module: PaladinClient.Test.Guardian
