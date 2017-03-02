defmodule Panglao.FilerController do
  use Panglao.Web, :controller

  alias Panglao.{Object, Builders}

  def index(conn, _params) do
    objects = Repo.all Object
    render conn, "index.html", objects: objects
  end

  def upload(conn, %{"src" => [src]}) do
    user_id = 0

    Repo.transaction(fn  ->
      with {:ok, object} <- Repo.insert(Object.changeset(%Object{}, %{"user_id" => user_id, "name" => src.filename})),
           {:ok, object} <- Repo.update(Object.object_changeset(object, %{"src" => src})) do
        object
      else
        {:error, changeset} -> Repo.rollback changeset
      end
    end)
    |> case do
      {:ok, object} ->
        Exq.enqueue Exq, "encoder", Builders.Encode, [object.id]

        msg = gettext("Sweet! You have exactly a brand new object")
        json conn, %{msg: msg, object: object}

      {:error, changeset} ->
        errors = Enum.map(changeset.errors, fn {field, msg} ->
          "#{translate_default field} #{translate_error msg}"
        end)

        msg = Enum.join([gettext "Upload error below:"] ++ errors, "\n")
        conn
        |> put_status(400)
        |> json(%{msg: msg})
    end
  end
end
