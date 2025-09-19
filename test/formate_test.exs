defmodule FormatTest do
  use ExUnit.Case

  # Tests para validate_line_format/2
    test "línea válida devuelve :ok" do
      valid_line = "1;1754937004;BTC;USDT;1.5;122;555;transfer"
      assert :ok = Ledger.FormatLedger.validate_line_format(valid_line, 1)
    end

    test "error cuando número de campos incorrecto" do
      # Falta un campo
      invalid_line = "1;1754937004;BTC;USDT;1.5;122;555"
      assert {:error, 1} = Ledger.FormatLedger.validate_line_format(invalid_line, 1)
    end

    test "error cuando ID no es entero válido" do
      invalid_line = "abc;1754937004;BTC;USDT;1.5;122;555;transfer"
      assert {:error, 1} = Ledger.FormatLedger.validate_line_format(invalid_line, 1)
    end

    test "error cuando timestamp no es entero válido" do
      invalid_line = "1;not_timestamp;BTC;USDT;1.5;122;555;transfer"
      assert {:error, 1} = Ledger.FormatLedger.validate_line_format(invalid_line, 1)
    end

    test "error cuando monto no es float válido" do
      invalid_line = "1;1754937004;BTC;USDT;not_number;122;555;transfer"
      assert {:error, 1} = Ledger.FormatLedger.validate_line_format(invalid_line, 1)
    end

    test "error cuando monto está vacío" do
      invalid_line = "1;1754937004;BTC;USDT;;122;555;transfer"
      assert {:error, 1} = Ledger.FormatLedger.validate_line_format(invalid_line, 1)
    end

    test "error cuando tipo de operación no es válido" do
      invalid_line = "1;1754937004;BTC;USDT;1.5;122;555;invalid_type"
      assert {:error, 1} = Ledger.FormatLedger.validate_line_format(invalid_line, 1)
    end

    test "operaiones válidas: transfer, alta_cuenta, swap" do
      valid_transfer = "1;1754937004;BTC;USDT;1.5;122;555;transfer"
      valid_alta = "1;1754937004;BTC;USDT;1.5;122;555;alta_cuenta"
      valid_swap = "1;1754937004;BTC;USDT;1.5;122;555;swap"

      assert :ok = Ledger.FormatLedger.validate_line_format(valid_transfer, 1)
      assert :ok = Ledger.FormatLedger.validate_line_format(valid_alta, 2)
      assert :ok = Ledger.FormatLedger.validate_line_format(valid_swap, 3)
    end


  # Tests para format_balance/1
  describe "format_balance/1" do
    test "formatea mapa de balances correctamente" do
      balance_map = %{"BTC" => 1.5, "USDT" => 50000.0, "ETH" => 2.0}

      assert {:ok, "BTC=1.5\nETH=2.0\nUSDT=5.0e4"} =
               Ledger.FormatLedger.format_balance({:ok, balance_map})
    end

    test "mapa vacío devuelve string vacío" do
      assert {:ok, ""} = Ledger.FormatLedger.format_balance({:ok, %{}})
    end

    test "un solo elemento en el mapa" do
      assert {:ok, "BTC=1.5"} = Ledger.FormatLedger.format_balance({:ok, %{"BTC" => 1.5}})
    end

    test "valores negativos se formatean correctamente" do
      balance_map = %{"BTC" => -1.5, "USDT" => -50000.0}

      assert {:ok, "BTC=-1.5\nUSDT=-5.0e4"} =
               Ledger.FormatLedger.format_balance({:ok, balance_map})
    end

    test "valores decimales con muchos decimales" do
      balance_map = %{"BTC" => 0.000001, "USDT" => 123.456789}

      assert {:ok, "BTC=1.0e-6\nUSDT=123.456789"}=
               Ledger.FormatLedger.format_balance({:ok, balance_map})
    end
  end

end
