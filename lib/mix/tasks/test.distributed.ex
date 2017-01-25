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
  @default_count 4

  def run(params) do
    unless System.get_env("MIX_ENV") || Mix.env == :test do
      Mix.raise "\"mix test.distributed\" is running on environment \"#{Mix.env}\". If you are " <>
                                "running tests along another task, please set MIX_ENV explicitly"
    end

    {switches, _, _} = OptionParser.parse(params, [switches: [count: :integer]])

    app = Mix.Project.config[:app]
    Application.ensure_started(app)

    Keyword.get(switches, :count, @default_count)
    |> start()

    Mix.Tasks.Test.run([])
    stop()
  end

  @doc false
  def start(num_nodes) do
    spawn_master()
    num_nodes
    |> spawn_slaves()
  end

  @doc false
  def stop() do
    Node.list()
    |> Enum.map(&:slave.stop/1)
    :net_kernel.stop()
  end

  defp spawn_master() do
    :net_kernel.start([:"primary@127.0.0.1"])
    :erl_boot_server.start([])
    allow_boot(~c"127.0.0.1")
  end

  defp spawn_slaves(num_nodes) do
    1..num_nodes
    |> Enum.map(fn index -> ~c"slave#{index}@127.0.0.1" end)
    |> Enum.map(&Task.async(fn -> spawn_slave(&1) end))
    |> Enum.map(&Task.await(&1, 30_000))
  end

  defp spawn_slave(node_host) do
    {:ok, node} = :slave.start(~c"127.0.0.1", node_name(node_host), inet_loader_args())
    add_code_paths(node)
    transfer_configuration(node)
    ensure_applications_started(node)
    {:ok, node}
  end

  defp rpc(node, module, function, args) do
    :rpc.block_call(node, module, function, args)
  end

  defp inet_loader_args do
    ~c"-loader inet -hosts 127.0.0.1 -setcookie #{:erlang.get_cookie()}"
  end

  defp allow_boot(host) do
    {:ok, ipv4} = :inet.parse_ipv4_address(host)
    :erl_boot_server.add_slave(ipv4)
  end

  defp add_code_paths(node) do
    rpc(node, :code, :add_paths, [:code.get_path()])
  end

  defp transfer_configuration(node) do
    for {app_name, _, _} <- Application.loaded_applications do
      for {key, val} <- Application.get_all_env(app_name) do
        rpc(node, Application, :put_env, [app_name, key, val])
      end
    end
  end

  defp ensure_applications_started(node) do
    rpc(node, Application, :ensure_all_started, [:mix])
    rpc(node, Mix, :env, [Mix.env()])
    for {app_name, _, _} <- Application.loaded_applications do
      rpc(node, Application, :ensure_all_started, [app_name])
    end
  end

  defp node_name(node_host) do
    node_host
    |> to_string()
    |> String.split("@")
    |> Enum.at(0)
    |> String.to_atom()
  end
end
