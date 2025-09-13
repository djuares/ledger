
defmodule CliTest do
  use ExUnit.Case

  import Ledger.CLI, only: [ parse_args: 1]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h",     "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end
  test "transaction default" do
    assert parse_args(["transaction"]) == {"transaction","data/input/trans.csv", "0", "data/output/default_result.csv" }
  end
    test "transaction with arguments" do
    assert parse_args(["transaction", "-t=input_file", "-c1=312", "-o=output_file"]) == {"transaction", "input_file", "312", "output_file"}
  end
  test "balance with arguments" do
    assert parse_args(["balance", "-c1=312", "-m=money_type"]) == {"balance","312", "money_type"}
  end
    test "balance default" do
    assert parse_args(["balance", "-c1=312"]) ==   {"balance", "312", "0"}
  end
end
