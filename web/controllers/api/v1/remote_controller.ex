defmodule Panglao.Api.V1.RemoteController do
  use Panglao.Web, :controller

  def upload(conn, _params) do
    json conn, ""
  end

  def status(conn, _params) do
    json conn, ""
  end

end
