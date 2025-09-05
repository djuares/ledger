defmodule Ledger.Transactions do
  def list(input_file, origin_account, output_file) do
    case open_input_file(input_file, origin_account) do
      content when is_binary(content) -> {:ok, content}
      error_message -> {:error, error_message}
      end
    end

   def open_input_file(input_file, "0") do
  case File.read(input_file) do
    {:ok, content} ->
      content
      |> String.split("\n")
      |> Enum.filter(&(&1 != ""))
      |> Enum.join("\n")

    {:error, error} ->
      "Error: #{:file.format_error(error)}"
    end
  end
  def open_input_file(input_file, origin_account) do
  case File.read(input_file) do
    {:ok, content} ->
      content
      |> String.split("\n")
      |> Enum.filter(&(&1 != ""))
      |> Enum.filter(fn line ->
        parts = String.split(line, ";")
        Enum.at(parts, 5) == origin_account || Enum.at(parts, 6) == origin_account
      end)
      |> Enum.join("\n")

    {:error, error} ->
      "Error: #{:file.format_error(error)}"
    end
  end

end
