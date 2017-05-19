defmodule Mix.Tasks.Test.Distributed do
  @moduledoc """
  Run tests for a distributed application.

  This mix task starts up a cluster of nodes before running the `Mix.Tasks.Test`
  mix task. The number of nodes to start (besides the master node) can be set
  using the "-count #" switch (defaults to 4). Each slave node will have the code
  and application environment from the master node loaded onto it.  All switches
  for the `mix test` task will be passed along to it.
  """
  use Mix.Task

  @shortdoc "Runs a project's tests in a distributed environment"
  @recursive true
  @preferred_cli_env :test

  @default_count 4

  def run(params) do
    unless System.get_env("MIX_ENV") || Mix.env == :test do
      IO.puts "⚑ “mix test.distributed” is running on environment “#{Mix.env}”.\n" <>
              "⚐   “mix test.distributed” is to be run on :test.\n" <>
              "⚐   Resetting the environment to :test for you."
      Mix.env(:test)
    end

    {switches, _, _} = OptionParser.parse(params, [switches: [count: :integer]])

    app = Mix.Project.config[:app]
    Mix.Tasks.Loadpaths.run([])
    Application.ensure_started(app)

    count = Keyword.get(switches, :count, @default_count)
    DistributedEnv.start_link(count, app)

    params = case Keyword.has_key?(switches, :count) do
      true -> remove_count(params)
      false -> params
    end
    Mix.Tasks.Test.run(params)

    DistributedEnv.stop()
  end

  defp remove_count(params, acc \\ [])
  defp remove_count([], acc), do: :lists.reverse(acc)
  defp remove_count(["--count"|[_num|rem]], acc), do: :lists.reverse(acc) ++ rem
  defp remove_count([head|rem], acc), do: remove_count(rem, [head|acc])
end
