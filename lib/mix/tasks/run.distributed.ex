defmodule Mix.Tasks.Run.Distributed do
  @moduledoc """
  Run a project in a distributed environment.

  This mix task starts up a cluster of nodes before running the `Mix.Tasks.Run`
  mix task. The number of nodes to start (besides the master node) can be set
  using the "-count #" switch (defaults to 4). Each slave node will have the code
  and application environment from the master node loaded onto it.  All switches
  for the `mix run` task will be passed along to it.
  """
  use Mix.Task

  @shortdoc "Runs a project in a distributed environment"
  @recursive true

  @default_count 4

  def run(params) do
    app = Mix.Project.config[:app]

    {switches, _, _} = OptionParser.parse(params, [switches: [count: :integer]])
    params = case Keyword.has_key?(switches, :count) do
      true -> remove_count(params)
      false -> params
    end
    Mix.Tasks.Run.run(["--no-start"|params])

    Application.ensure_started(:distributed_test)
    Keyword.get(switches, :count, @default_count)
    |> DistributedEnv.start()

    config_path = Mix.Project.config[:config_path]
    :rpc.eval_everywhere(Node.list(), Mix.Config, :read!, [config_path])

    :rpc.eval_everywhere(Application, :ensure_all_started, [app])
  end

  defp remove_count(params, acc \\ [])
  defp remove_count([], acc), do: :lists.reverse(acc)
  defp remove_count(["--count"|[_num|rem]], acc), do: :lists.reverse(acc) ++ rem
  defp remove_count([head|rem], acc), do: remove_count(rem, [head|acc])
end
