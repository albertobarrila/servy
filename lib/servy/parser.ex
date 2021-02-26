defmodule Servy.Parser do
  @moduledoc """
    parser for servy
  """

  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")
    IO.puts(top)
    [request_line | header_lines] = String.split(top, "\r\n")
    IO.puts(request_line)
    IO.puts(header_lines)
    [method, path, _] = String.split(request_line, " ")
    headers = parse_headers(header_lines, %{})
    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      headers: headers,
      params: params
    }
  end

    @doc """
  Parses the given param string of the form 'key1=value1&key2=value2'
  into a map with corresponding keys and values.

  ## Examples
  iex> params_string = "name=Baloo&type=Brown"
  iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
  %{"name" => "Baloo", "type" => "Brown"}
  iex> Servy.Parser.parse_params("multipart/form-data", params_string)
  %{}
  """
  @spec parse_params(any, any) :: %{optional(binary) => binary}
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end

  def parse_params(_, _) do
    %{}
  end

  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers
end
