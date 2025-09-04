defmodule Ledger.CLI do

 @default [input_file: "transactions.csv", origin_account: 0, output_file: "response.csv"]
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns   `:help`.

  Otherwise it is a transaction ó balance subcommand
  """
  def parse_args(argv) do
    OptionParser.parse(
      argv,
      switches: [
        help: :boolean,
        c1: :string,
        c2: :string,
        t: :string,
        m: :string,
        o: :string
      ],
      aliases: [
        h: :help,
        c1: :c1,
        c2: :c2,
        t: :t,
        m: :m,
        o: :o
      ]
    )
    |> elem(1)
    |> args_to_internal_representation()
  end

  def args_to_internal_representation(["transaction"]) do
      {"transaction", @default[:input_file], @default[:origin_account], @default[:output_file]}
  end
  def args_to_internal_representation(["transaction", input_file, origin_account, output_file]) do
    {"transaction", input_file,  String.to_integer(origin_account), output_file}
  end
  def args_to_internal_representation(["balance", origin_account, money_type]) do
      {"balance", String.to_integer(origin_account), money_type}
  end
  def args_to_internal_representation(["balance",  origin_account]) do
      {"balance", String.to_integer(origin_account)}

  end

  def args_to_internal_representation(_) do
    :help
  end

  def process(:help) do
    IO.puts """
    usage:
        ./ledger transaction -t=input_file.csv -c1=origin_account -o=output_file.csv

        ./ledger balance -c1=origin_account -m=money_type

    """
    System.halt(0)
  end
  """
  def process({"transaction", input_file, origin_account, output_file}) do
    Ledger.transaction("transaction", input_file, origin_account, output_file)
    |> decode_response()
  end
  def process({ {"balance",origin_account, money_type}}) do
    Ledger.balance( {"balance",origin_account, money_type})   #Resolver casos por default de flags no pasados
    |> decode_response()
  end
  def decode_response({:ok, body}), do: body

  def decode_response({:error, line_number}) do
    IO.inspect({:error, line_number})
    System.halt(2)
  end
"""


end
