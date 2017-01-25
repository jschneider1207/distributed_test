defmodule DistributedEnvTest do
  use ExUnit.Case

  test "nodes are stopped and started at will" do
    count = 6

    DistributedEnv.start(count)
    assert length(Node.list()) === count

    DistributedEnv.stop()
    assert length(Node.list()) === 0
  end
end
