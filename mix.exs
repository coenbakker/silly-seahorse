defmodule SillySeahorse.MixProject do
  use Mix.Project
  @github_url "https://github.com/coenbakker/SillySeahorse"

  def project do
    [
      app: :silly_seahorse,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: ~s|Create random usernames like "silly_seahorse" and "anxious-turtle".|,
      source_url: @github_url,
      homepage_url: @github_url,
      files: ~w(mix.exs lib LICENSE.md README.md CHANGELOG.md),
      package: [
        maintainers: ["Coen Bakker"],
        licenses: ["MIT"],
        links: %{
          "GitHub" => @github_url
        }
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  def package do
    [
      name: "silly_seahorse",
      files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github_url}
    ]
  end
end
