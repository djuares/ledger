defmodule Ledger.Balance do

def list(origin_account, money_type) do
  input_file = "data/input/trans.csv"

  case File.read(input_file) do
    {:ok, content} ->
      case process_content(content, origin_account, money_type) do
        {:error, message} ->
          {:error, message}
        total_balance ->
          formatted_result = Ledger.FormatLedger.format_balance(total_balance)
          formatted_result
      end
    {:error, reason} ->
      {:error, "No se pudo leer el archivo: #{reason}"}
  end
end

def process_content(content, origin_account, "0") do
  lines = content
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.with_index(1)

  validation_result = Enum.reduce_while(lines, :ok, fn {line, line_number}, acc ->
    case Ledger.FormatLedger.validate_line_format(line, line_number) do
      :ok -> {:cont, acc}
      {:error, message} -> {:halt, {:error, message}}
    end
  end)

  case validation_result do
    {:error, message} ->
      {:error, message}


    :ok ->
      {list_5, list_6} = Enum.reduce(lines, {[], []}, fn {line, _line_number}, {acc_5, acc_6} ->
        parts = String.split(line, ";")

        cond do
          Enum.at(parts, 5) == origin_account && Enum.at(parts, 7) == "transfer" ->
            {[line | acc_5], acc_6}
          Enum.at(parts, 6) == origin_account && Enum.at(parts, 7) == "transfer" ->
            {acc_5, [line | acc_6]}
          Enum.at(parts, 5) == origin_account && Enum.at(parts, 7) == "alta_cuenta" ->
            {acc_5, [line | acc_6]}
          Enum.at(parts, 5) == origin_account && Enum.at(parts, 7) == "swap" ->
            {acc_5, [line | acc_6]}
          Enum.at(parts, 6) == origin_account ->
            {acc_5, [line | acc_6]}
          true ->
            {acc_5, acc_6}
        end
      end)
      |> then(fn {l5, l6} -> {Enum.reverse(l5), Enum.reverse(l6)} end)

      result2 = Ledger.Debit.debit_balance(list_5)
      result = Ledger.Acredit.acredit_balance(list_6)
      total_balance = combine_balances(result, result2)
      {:ok, total_balance}
  end
end

def process_content(content, origin_account, money_type) do
  case process_content(content, origin_account, "0") do
    {:ok, balance_map} ->
      case Ledger.Conversion.convert_all_balances(balance_map, money_type) do
        {:ok, converted_balance} -> {:ok, converted_balance}
        {:error, message} -> {:error, message}
      end

    {:error, message} ->
      {:error, message}
  end
end

defp combine_balances(acredit_balances, debit_balances) do
  Map.merge(acredit_balances, debit_balances, fn _currency, acredit_amount, debit_amount ->
    acredit_amount + debit_amount
  end)
end

end
