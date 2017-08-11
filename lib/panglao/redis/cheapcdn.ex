defmodule Panglao.Redis.Cheapcdn do
  defmodule Client do
    use Rdtype,
      uri: Application.get_env(:panglao, :redis)[:cheapcdn],
      coder: Panglao.Redis.Json,
      type: :string
  end

  defp hkey(key) do
    :crypto.hash(:md5, '#{key}')
    |> Base.encode16(case: :lower)
  end

  def get(key) do
    Client.get hkey(key)
  end

  def set(key, value) do
    Client.set hkey(key), value
  end

  def del(key) do
    Client.del hkey(key)
  end

end
