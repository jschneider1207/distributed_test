defmodule Mix.Tasks.Test.DistributedTest do
    use ExUnit.Case
    alias Mix.Tasks.Test.Distributed

    test "nodes are stopped and started at will" do
      count = 6

      Distributed.start(count)
      assert length(Node.list()) === count

      Distributed.stop()
      assert length(Node.list()) === 0
    end
end
