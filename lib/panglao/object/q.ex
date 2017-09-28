defmodule Panglao.Object.Q do
  alias Panglao.{RepoReader, Object, Hash}

  def get!(%{"id" => hash}) do
    with id when not is_nil(id) <- Hash.decrypt(hash),
         o <- RepoReader.gets!(Object, id) do
      o
    else _ ->
      raise Ecto.NoResultsError
    end
  end

  def get!(%{"user_id" => user_id, "url" => url}) do
    RepoReader.gets_by!(Object, user_id: user_id, url: url)
  end

  def get(%{"user_id" => user_id, "url" => url}) do
    RepoReader.gets_by(Object, user_id: user_id, url: url) || %Object{}
  end

end
