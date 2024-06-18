defmodule SillySeahorse.MixProject do
  use Mix.Project

  @github_url "https://github.com/coenbakker/SillySeahorse"

  def project do
    [
      app: :silly_seahorse,
      version: "0.1.2",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "silly_seahorse",
      source_url: @github_url,
      dialyzer: [
        plt_add_deps: :apps_direct,
        plt_add_apps: [:mix]
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
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp description do
    """
    Create random usernames like "silly_seahorse" and "anxious-turtle".
    """
  end

  defp package do
    [
      name: "silly_seahorse",
      files: ~w(lib .formatter.exs mix.exs LICENSE.md README.md CHANGELOG.md),
      licenses: ["MIT"],
      links: %{"GitHub" => @github_url}
    ]
  end
end
