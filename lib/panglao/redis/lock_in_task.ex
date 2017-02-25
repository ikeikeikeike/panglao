defmodule Panglao.Redis.LockInTask do
  defmodule Base do
    use Rdtype,
      uri: Application.get_env(:panglao, :redis)[:lock_in_task],
      coder: Panglao.Redis.Json,
      type: :string
  end

end
