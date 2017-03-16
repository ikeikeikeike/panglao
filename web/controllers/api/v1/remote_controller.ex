defmodule Panglao.Api.V1.RemoteController do
  use Panglao.Web, :controller

  def upload(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    json conn, user.id
  end

  def status(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    json conn, user.email
  end

end
