defmodule Panglao.Func do

  def themodule(%{__struct__: module}), do: module
  def themodule(module), do: module

  def thename(mod) do
    mod
    |> themodule()
    |> to_string
    |> String.split(".")
    |> List.last
    |> String.downcase
  end

  def fint!(numeric) when is_integer(numeric) do
    numeric
  end
  def fint!(numeric) when is_float(numeric) do
    round numeric
  end
  def fint!(numeric) when is_binary(numeric) do
    {n, _} = Integer.parse numeric
     n
  end
  def fint!(_), do: raise FunctionClauseError
end
