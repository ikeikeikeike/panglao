defmodule Panglao.RemoteController do
  use Panglao.Web, :controller

  alias Panglao.{Object, Builders}

  def index(conn, _params) do
    render conn, "index.html"
  end

  def upload(conn, %{"message" => message}) do
    user_id  = 0
    remotes  = String.split message, "\n"

    results =
      Enum.map remotes, fn remote ->
        params = %{"user_id" => user_id, "remote" => remote}
        Repo.insert(Object.remote_changeset(%Object{}, params))
      end

    message =
      Enum.map results, fn
        {:ok, object} ->
          spawn fn ->
            case Client.get object.remote do
              {:ok, r} ->
                r.body
              _ ->
                nil
            end
          end
          ""

        {:error, changeset} ->
          errors =
            Enum.map(changeset.errors, fn {field, msg} ->
              "#{translate_default field} #{translate_error msg}"
            end)

          Enum.join errors, "\n"
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
