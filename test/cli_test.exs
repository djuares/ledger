
defmodule CliTest do
  use ExUnit.Case

  import Ledger.CLI, only: [ parse_args: 1]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h",     "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end
  test "only values returned if only given" do
    assert parse_args(["transaction"]) == {"transaction","trans.csv", "0", "default_result.csv" }
  end
    test "four values returned if three given" do
    assert parse_args(["transaction", "-t=input_file", "-c1=312", "-o=output_file"]) == {"transaction", "input_file", "312", "output_file"}
  end
  test "three values returned if three given" do
    assert parse_args(["balance", "-c1=312", "-m=money_type"]) == {"balance","312", "money_type"}
  end
    test "two values returned if two given" do
    assert parse_args(["balance", "-c1=312"]) ==   {"balance", "312", "0"}
  end
end
