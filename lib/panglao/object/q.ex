defmodule Panglao.Object.Q do
  alias Panglao.{Repo, Object, Hash}

  def get!(%{"id" => hash}) do
    with id when not is_nil(id) <- Hash.decrypt(hash),
         o <- Repo.get!(Object, id) do
      o
    else _ ->
      raise Ecto.NoResultsError
    end
  end

  def get!(%{"user_id" => user_id, "url" => url}) do
    Repo.get_by! Object, user_id: user_id, url: url
  end
end
