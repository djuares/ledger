defmodule Ledger.Balance do

  def list(origin_account, money_type) do
    input_file = "trans.csv"

    case File.read(input_file) do
      {:ok, content} ->
        total_balance = process_content(content, origin_account, money_type)
        formatted_result = format_balance(total_balance)
        {:ok, formatted_result}

      {:error, reason} ->
        {:error, "No se pudo leer el archivo: #{reason}"}
    end
  end

defp process_content(content, origin_account, "0") do
  {list_5, list_6} = content
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.reduce({[], []}, fn line, {acc_5, acc_6} ->
      parts = String.split(line, ";")

      cond do
        Enum.at(parts, 5) == origin_account ->
          {[line | acc_5], acc_6}
        Enum.at(parts, 6) == origin_account ->
          {acc_5, [line | acc_6]}
        true ->
          {acc_5, acc_6}
      end
    end)
    |> then(fn {l5, l6} -> {Enum.reverse(l5), Enum.reverse(l6)} end)
  result = acredit_balance(list_6)
  result2 = debit_balance(list_5)
  total_balance = combine_balances(result, result2)
  total_balance
end

defp process_content(content, origin_account, money_type) do
  balance_map=process_content(content, origin_account, "0")
  balance_convert= convert_all_balances(balance_map, money_type)
  balance_convert
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

defp acredit_balance(accreditations) do
    Enum.reduce(accreditations, %{}, fn accreditation, acc ->
      [_, _, moneda_origen, moneda_destino, monto_str, _, _, _] = String.split(accreditation, ";")
      {monto, _} = Float.parse(monto_str)
      with {:ok, converted_amount} <- convert(moneda_origen, moneda_destino, monto) do
        Map.update(acc, moneda_destino, converted_amount, &(&1 + converted_amount))
      else
        _ -> acc  # En caso de error en la conversión, simplemente ignorar esta transacción
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

defp combine_balances(acredit_balances, debit_balances) do
  Map.merge(acredit_balances, debit_balances, fn _currency, acredit_amount, debit_amount ->
    acredit_amount + debit_amount
  end)
end

  # Función para formatear el balance como string
defp format_balance(balance_map) do
    balance_map
    |> Enum.map(fn {currency, amount} ->
      "#{currency}: #{Float.round(amount, 6)}"
    end)
    |> Enum.join("\n")
end


defp convert(money1, money2, amount) do
    currencies = load_currencies()
    money1_up = String.upcase(money1)
    money2_up = String.upcase(money2)

    if Map.has_key?(currencies, money1_up) and Map.has_key?(currencies, money2_up) do
      rate1 = currencies[money1_up]
      rate2 = currencies[money2_up]

      intermediate = amount * rate1
      result = intermediate * rate2
      final_result = Float.round(result, 6)

      {:ok, final_result}
    else
      {:error, "Una o ambas monedas no son válidas"}
    end
end


defp load_currencies() do
  case File.read("money.csv") do
    {:ok, content} ->
      currencies_map = content
        |> String.split("\n", trim: true)
        |> Enum.map(&String.split(&1, ";"))
        |> Enum.reduce(%{}, fn [currency, rate], acc ->
          {rate_float, _} = Float.parse(rate)
          Map.put(acc, String.upcase(currency), rate_float)
        end)

      currencies_map

    {:error, reason} ->
      # Valores por defecto en caso de que el archivo no exista
      default_currencies = %{
        "BTC" => 55000.0,
        "ETH" => 3000.0,
        "ARS" => 0.0012,
        "USDT" => 1.0,
        "EUR" => 1.18
      }
      default_currencies
  end
end

end
