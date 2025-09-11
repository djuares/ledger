defmodule Ledger.CLI do
  @default [input_file: "trans.csv", origin_account: "0", output_file: "default_result.csv", money_type: "0"]

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    {opts, args, _} = OptionParser.parse(
      argv,
      switches: [
        help: :boolean,
        t: :string,
        c: :string,
        o: :string,
        m: :string
      ],
      aliases: [
        h: :help,
        t: :t,
        c1: :c,
        o: :o,
        m: :m

      ]
    )
    {args, opts}
    |> args_to_internal_representation()
  end

  def args_to_internal_representation({["transaction"], opts}) do
    input_file = opts[:t] || @default[:input_file]
    origin_account = opts[:c] || @default[:origin_account]
    output_file = opts[:o] || @default[:output_file]

    {"transaction", input_file, origin_account, output_file}
  end

  def args_to_internal_representation({["balance"], opts}) do
    origin_account = opts[:c]
    money_type = opts[:m] || @default[:money_type]

    {"balance", origin_account, money_type}
  end

  def args_to_internal_representation(_) do
    :help
  end

  def process(:help) do
    IO.puts("""
    usage:
        ./ledger transaction -t=input_file.csv -c=origin_account -o=output_file.csv
        ./ledger balance -c=origin_account -m=money_type
    """)
    System.halt(0)
  end

  def process({"transaction", input_file, origin_account, output_file}) do
    Ledger.Transactions.list(input_file, origin_account, output_file)
    |> decode_response()
    |> IO.puts()
  end

  def process({"balance", origin_account, money_type}) do
    Ledger.Balance.list(origin_account, money_type)
    |> decode_response()
    |> IO.puts()
  end

  def decode_response({:ok, body}), do: body
  def decode_response({:error, reason}), do: "Error: #{reason}"
end
