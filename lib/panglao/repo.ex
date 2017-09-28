defmodule Panglao.Repo do
  use Ecto.Repo, otp_app: :panglao
end

defmodule Panglao.RepoReader do
  use Ecto.Repo, otp_app: :panglao

  def gets(queryable, id, opts \\ []) do
    with r when is_nil(r) <- get(queryable, id, opts),
         r <- Panglao.Repo.get(queryable, id, opts) do
      r
    end
  end

  def gets!(queryable, id, opts \\ []) do
    with r when is_nil(r) <- get(queryable, id, opts),
         r <- Panglao.Repo.get!(queryable, id, opts) do
      r
    end
  end

  def gets_by(queryable, clauses, opts \\ []) do
    with r when is_nil(r) <- get_by(queryable, clauses, opts),
         r <- Panglao.Repo.get_by(queryable, clauses, opts) do
      r
    end
  end

  def gets_by!(queryable, clauses, opts \\ []) do
    with r when is_nil(r) <- get_by(queryable, clauses, opts),
         r <- Panglao.Repo.get_by!(queryable, clauses, opts) do
      r
    end
  end
end
