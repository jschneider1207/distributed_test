defmodule DistributedTest.Mixfile do
  use Mix.Project

  def project do
    [app: :distributed_test,
     version: "0.2.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.14.5", only: :dev}]
  end

  defp description do
    """
    Run tests in a distributed environment!
    """
  end

  defp package do
    [
     name: :distributed_test,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Sam Schneider"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/sschneider1207/distributed_test"}]
  end
end
