
defmodule BalanceTest do
  use ExUnit.Case


  test "Balance calcula balance por cuenta coorectamente" do
    assert Ledger.Balance.list("122", "0") ==  {:ok, "ARS=0.0\nBTC=0.0\nETH=36.666667\nUSDT=5.5e3"}
  end
  test "Balance calcula balance por cuenta en tipo de moneda correctamente" do
    assert Ledger.Balance.list("122", "BTC") ==  {:ok, "BTC=2.1"}
  end
  test "Balance calcula balance corectamente para cuenta sin movimientos" do
    assert Ledger.Balance.list("999", "0") ==  {:ok, ""}
  end
  test "Balance calcula balance en moneda corectamente para cuenta sin movimientos" do
    assert Ledger.Balance.list("999", "BTC") ==  {:ok, "BTC=0.0"}
  end
  test "No se calcula balance para archivo csv que no cumple el formato" do
    corrupt_content = "1754937004;BTC;USDT;no_es_numero;122;555;transfer"
    assert Ledger.Balance.process_content(corrupt_content, "122", "0") == {:error, 1}
  end
end
