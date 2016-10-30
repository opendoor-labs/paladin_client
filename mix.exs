defmodule PaladinClient.Mixfile do
  use Mix.Project

  @version "0.2.0"
  @maintainers ["Daniel Neighman"]
  @homepage_url "https://github.com/opendoor-labs/paladin_client"
  @source_url "https://github.com/opendoor-labs/paladin_client"
  @name "Paladin Client"

  def project do
    [app: :paladin_client,
     version: @version,
     name: @name,
     package: package,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     source_url: @source_url,
     homepage_url: @homepage_url,
     description: description,
     docs: docs,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: applications(Mix.env),
     mod: {PaladinClient, []},
    ]
  end

  defp applications(:test) do
    applications ++ [:bypass, :phoenix]
  end

  defp applications(:dev) do
    applications ++ [:phoenix]
  end

  defp applications(_), do: applications
  defp applications() do
    [:logger, :httpoison, :guardian]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [ {:bypass, "~> 0.5", only: [:test]},
      {:guardian, "~> 0.13"},
      {:httpoison, "~> 0.9"},
      {:poison, "~> 2.0"},
      {:phoenix, "~> 1.2", only: [:dev, :test]},
      {:ex_doc, "~> 0.12", only: :dev},
    ]
  end

  defp docs do
    [docs: [source_ref: "v#{@version}", main: @name,
           canonical: "http://hexdocs.pm/paladin_client",
           source_url: @source_url,
           extras: ["README.md"]]]
  end

  defp description do
    """
    Provides helper functions and a Read-Through cache for interacting with Paladin
    """
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE.md", "CHANGELOG.md"],
     maintainers: @maintainers,
     licenses: ["MIT"],
     links: %{"GitHub": "https://github.com/opendoor-labs/paladin_client"}]
  end
end
