defmodule Panglao.Api.V1.UserController do
  use Panglao.Web, :controller

  def info(conn, _params) do
    user = conn.assigns.current_user
    json conn, user.id
  end
end
