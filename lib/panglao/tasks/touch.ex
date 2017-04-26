defmodule Panglao.Tasks.Touch do
  def perform do
    :os.cmd 'date > /tmp/quantum'
  end
end
