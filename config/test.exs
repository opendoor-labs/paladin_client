use Mix.Config

config :guardian, Guardian,
  serializer: PaladinClient.Test.GuardianSerializer,
  issuer: "paladin_client_test",
  secret_key: "test"

config :paladin_client, PaladinClient,
  adapter: PaladinClient.InMemory,
  url: "http://localhost:4000",
  apps: [
    one: "one-app-id",
    two: "two-app-id",
  ]
