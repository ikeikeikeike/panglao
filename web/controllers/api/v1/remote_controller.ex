defmodule Panglao.Api.V1.RemoteController do
  use Panglao.Web, :controller

  alias Panglao.{Object.Remote, Client.Progress}

  def upload(conn, %{"remote" => remote}) do
    user_id  = conn.assigns.current_user.id
    params   = %{"user_id" => user_id, "remote" => String.trim(remote)}

    case Remote.upload(params) do
      {:error, %Ecto.Changeset{} = c} ->
        errors = Enum.map c.errors, fn {field, msg} ->
          "#{translate_default field} #{translate_error msg}"
        end
        json conn, Enum.join(errors, "\n")

      {:error, message} ->
        json conn, "#{message}"

      {:ok, object} ->
        json conn, object  # json conn, %{name: o.name, remote: o.remote, src: o.src}
    end
  end

  def status(conn, %{"remote" => remote}) do
    case Progress.get(remote) do
      {:ok, r} ->
        json conn, Enum.into(r.body, %{})
      _        ->
        json conn, %{}
    end
  end

end
