defmodule Panglao.RemoteController do
  use Panglao.Web, :controller

  alias Panglao.{Object, Object.Remote, Client.Progress}

  def index(conn, _params) do
    objects = Repo.all Object.with_remote
    render conn, "index.html", objects: objects
  end

  def progress(conn, %{"remote" => remote}) do
    case Progress.get(remote) do
      {:ok, r} ->
        json conn, Enum.into(r.body, %{})

      _        ->
        json conn, %{}
    end
  end

  def upload(conn, %{"message" => message}) do
    user_id  = conn.assigns.current_user.id
    remotes  = String.split message, "\n"

    results =
      Enum.map remotes, fn remote ->
        params = %{"user_id" => user_id, "remote" => String.trim(remote)}
        Remote.upload params
      end

    message =
      Enum.map results, fn
        {:error, %Ecto.Changeset{} = c} ->
          errors = Enum.map c.errors, fn {field, msg} ->
            "#{translate_default field} #{translate_error msg}"
          end
          Enum.join errors, "\n"

        {:error, message} ->
          "#{message}"

        _ ->
          ""
      end

    conn =
      if blank? message do
        msg = gettext "Sweet! Remote uploading successfully"
        put_flash conn, :info, msg
      else
        msb = gettext("Upload error below:") <> Enum.join(message, "\n")
        put_flash conn, :error, msb
      end

    conn
    |> redirect(to: remote_path(conn, :index))
  end

end
