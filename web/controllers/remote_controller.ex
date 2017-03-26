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
    user_id = conn.assigns.current_user.id
    remotes = String.split message, "\n"

    results =
      Enum.map remotes, fn remote ->
        params = %{"user_id" => user_id, "remote" => String.trim(remote)}

        case Remote.upload(params) do
          {:error, %Ecto.Changeset{} = c} ->
            errors = Enum.map c.errors, fn {field, msg} ->
              "#{translate_default field} #{translate_error msg}"
            end
            {:error, Enum.join(errors, "\n")}

          {:error, msg} ->
            {:error, gettext("%{name} error happened %{msg}", name: remote, msg: msg)}

          {:ok, object} ->
            message =
              cond do
                Object.remote?(object) ->
                  gettext "%{name} is downloading in progress", name: object.name
                Object.object?(object) ->
                  gettext "%{name} became persistent file already", name: object.name
                true ->
                  gettext "%{name} still work in progress", name: object.name
              end
            {:ok, message}
        end
      end

    info = Enum.filter_map(results, &elem(&1, 0) == :ok, &elem(&1, 1)) |> Enum.join("<br/>")
    error = Enum.filter_map(results, &elem(&1, 0) == :error, &elem(&1, 1)) |> Enum.join("<br/>")

    conn = if present?(info), do: put_flash(conn, :info, gettext("Sweet! Remote uploading successfully below:<br/>") <> info), else: conn
    conn = if present?(error), do: put_flash(conn, :error, gettext("Upload error below:<br/>") <> error), else: conn
    conn
    |> redirect(to: remote_path(conn, :index))
  end

end
