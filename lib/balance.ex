defmodule Ledger.Balance do

def list(origin_account, money_type) do
  input_file = "data/input/trans.csv"

  case File.read(input_file) do
    {:ok, content} ->
      case process_content(content, origin_account, money_type) do
        {:error, message} ->
          {:error, message}
        total_balance ->
          formatted_result = format_balance(total_balance)
          formatted_result
      end
    {:error, reason} ->
      {:error, "No se pudo leer el archivo: #{reason}"}
  end
end

defp process_content(content, origin_account, "0") do
  lines = content
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.with_index(1)

  validation_result = Enum.reduce_while(lines, :ok, fn {line, line_number}, acc ->
    case validate_line_format(line, line_number) do
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

      result2 = debit_balance(list_5)
      result = acredit_balance(list_6)
      total_balance = combine_balances(result, result2)
      {:ok, total_balance}
  end
end

defp process_content(content, origin_account, money_type) do
  balance_map=process_content(content, origin_account, "0")
  balance_convert= convert_all_balances(balance_map, money_type)
  balance_convert
end

defp validate_line_format(line, line_number) do
  parts = String.split(line, ";")

  cond do
    length(parts) != 8 ->
      {:error, line_number}

    not is_valid_integer(Enum.at(parts, 0)) ->
      {:error, line_number}

    not is_valid_integer(Enum.at(parts, 1)) ->
      {:error, line_number}

    Enum.at(parts, 4) == "" or not is_valid_float(Enum.at(parts, 4)) ->
      {:error, line_number}

    Enum.at(parts, 7) not in ["transfer", "alta_cuenta", "swap"] ->
      {:error, line_number}

    true ->
      :ok
  end
end

defp is_valid_integer(string) do
  case Integer.parse(string) do
    {_int, ""} -> true
    _ -> false
  end
end

defp is_valid_float(string) do
  case Float.parse(string) do
    {_float, ""} -> true
    _ -> false
  end
end

defp acredit_balance(accreditations) do
  Enum.reduce(accreditations, %{}, fn accreditation, acc ->
    [_, _, moneda_origen, moneda_destino, monto_str, _, _, tipo_operacion] = String.split(accreditation, ";")
    {monto, _} = Float.parse(monto_str)

    case tipo_operacion do
      "swap" ->
        with {:ok, converted_amount} <- convert(moneda_origen, moneda_destino, monto) do
          acc
          |> Map.update(moneda_origen, -monto, &(&1 - monto))  # Restar de moneda origen
          |> Map.update(moneda_destino, converted_amount, &(&1 + converted_amount))  # Sumar a moneda destino
        else
          _ -> acc
        end

      _ ->
        case moneda_destino do
          "" ->
            Map.update(acc, moneda_origen, monto, &(&1 + monto))

          destino ->
            with {:ok, converted_amount} <- convert(moneda_origen, destino, monto) do
              Map.update(acc, destino, converted_amount, &(&1 + converted_amount))
            else
              _ -> acc
            end
        end
    end
  end)
end
defp debit_balance(debits) do
    Enum.reduce(debits, %{}, fn debit, acc ->
      [_, _, moneda_origen, _, monto_str, _, _, _] = String.split(debit, ";")
      {monto, _} = Float.parse(monto_str)
      Map.update(acc, moneda_origen, -monto, &(&1 - monto))
    end)
end

defp convert_all_balances(balance_map, money_type) do
  total = Enum.reduce(balance_map, 0.0, fn {currency, amount}, acc ->
    if currency == money_type do
      acc + amount
    else
      case convert(currency, money_type, amount) do
        {:ok, converted_amount} -> acc + converted_amount
        {:error, _} -> acc  # Ignorar si no se puede convertir
      end
    end
  end)

  %{money_type => total}
end


defp combine_balances(acredit_balances, debit_balances) do
  Map.merge(acredit_balances, debit_balances, fn _currency, acredit_amount, debit_amount ->
    acredit_amount + debit_amount
  end)
end

defp format_balance({:ok, balance_map}) do
  formatted_balance = balance_map
    |> Enum.map(fn {currency, amount} ->
      "#{currency}=#{amount}"
    end)
    |> Enum.join("\n")

  {:ok, formatted_balance}
end


defp convert(money1, money2, amount) do
    currencies = load_currencies()
    money1_up = String.upcase(money1)
    money2_up = String.upcase(money2)

    if Map.has_key?(currencies, money1_up) and Map.has_key?(currencies, money2_up) do
      rate1 = currencies[money1_up]
      rate2 = currencies[money2_up]

      intermediate = amount * rate1
      result = (intermediate / rate2)
      final_result = Float.round(result, 6)

      {:ok, final_result}
    else
      {:error, "Una o ambas monedas no son válidas"}
    end
  end

defp load_currencies() do
  case File.read("data/input/money.csv") do
    {:ok, content} ->
      currencies_map = content
        |> String.split("\n", trim: true)
        |> Enum.map(&String.split(&1, ";"))
        |> Enum.reduce(%{}, fn [currency, rate], acc ->
          {rate_float, _} = Float.parse(rate)
          Map.put(acc, String.upcase(currency), rate_float)
        end)
      currencies_map
  end
end

end
