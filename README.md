# PaladinClient

This client provides helper functions and a Read-Through cache for interacting with [Paladin](https://github.com/opendoor-labs/paladin)

Paladin provides detailed ACL for services to communicate with one-another either using an service assertion or on behalf of an existing user.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `paladin_client` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:paladin_client, "~> 0.2.0"}]
    end
    ```

  2. Ensure `paladin_client` is started before your application:

    ```elixir
    def application do
      [applications: [:paladin_client]]
    end
    ```

## Configuration

Visit your Paladin instance and register your application. 
You'll need it's ID to use as your Guardian issuer and set your Guardian secret key to the secret Paladin gives you.

```elixir
config :guardian, Guardian,
  issuer: "my-paladin-app-id",
  secret_key: "secret_from_paladin"
  ...
```
      
When you add PaladinClient to your application you'll need to add some configuration

* `adapter` Use `PaladinClient.HttpClient` for a live client. Use `PaladinClient.InMemory` for testing.
* `url` The url of the paladin install. E.g. `https://my-paladin-install.my-site.com`
* `apps` A Keyword list where the keys are the name/reference of apps you talk to, and the value is their Paladin ID.

## Usage

You can use PaladinClient in a number of different ways. 

1. As a plain service talking to another service. No user involved.
2. Speaking to another service on behalf of a user. e.g. Receive a request from user X, request to service A as user X

### Outside the context of a User

Meaning that our service wants to communicate with another service.
It's no on behalf of a particular user.

When we do this we use the the service id as the subject. Provided the receiving server can deal with it.

```elixir
case PaladinClient.service_token(:some_app) do
  {:ok, jwt} ->
    do_your_thing(jwt)
  {:error, reason} -> {:oh_no}
end
```

### Inside the context of a user

When you are acting on behalf of a user, you can use either an existing JWT that Guardian can verify using your secret, 
or you can have PaladinClient generate a new one for the user.

Note that the way you encode the user into the token must be understood by the receiving application

#### With an existing token

```elixir
result = PaladinClient.from_existing_token(user_jwt_for_my_app, :some_other_app)
case result do
  {:ok, token_to_use_with_some_other_app } ->
    do_something(token_to_use_with_some_other_app)
  {:error, reason} -> {:bad, :things}
end
```

#### With a user but no existing token

```elixir
{:ok, jwt} = PaladinClient.new_assertion_token(:some_app, user)
{:ok, some_other_jwt} = PaladinClient.from_existing_token(jwt, :some_other_app)
```

## License

Please see [LICENSE](https://github.com/opendoor-labs/pilgrim_client/blob/master/LICENSE) for licensing details.
