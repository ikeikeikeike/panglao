defmodule Panglao.Cron.Caller do

  @hoston Application.get_env(:panglao, __MODULE__)

  defp call(fun) do
    with {:ok, [{_, _, _}| _] = ifcnf} <- :inet.getif() do
      call fun, ifcnf
    else error ->
      error
    end
  end
  defp call(_, []) do
    {:error, "N/A"}
  end
  defp call(fun, [{@hoston, _, _} | _]) do
    fun.()
  end
  defp call(fun, [_ | tail]) do
    call fun, tail
  end

  def remove_perform do
    call fn ->
      Panglao.Tasks.Remove.perform
    end
  end

  def remove_perform_disksize do
    call fn ->
      Panglao.Tasks.Remove.perform :disksize
    end
  end

  def cleanup_unses_files do
    call fn ->
      Panglao.Tasks.Cleanup.unses_files
    end
  end

  def touch_perform do
    call fn ->
      Panglao.Tasks.Touch.perform
    end
  end

  def notify_perform do
    call fn ->
      Panglao.Tasks.Notify.perform
    end
  end

end
