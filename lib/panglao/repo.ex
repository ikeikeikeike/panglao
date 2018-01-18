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

  def execute_and_load(sql) do
    execute_and_load(sql, [])
  end
  def execute_and_load(sql, params) do
    Ecto.Adapters.SQL.query!(__MODULE__, sql, params)
    |> load_into()
  end
  def execute_and_load(sql, params, model) do
    Ecto.Adapters.SQL.query!(__MODULE__, sql, params)
    |> load_into(model)
  end

  defp load_into(qs) do
    cols = Enum.map qs.columns, & String.to_atom(&1)

    Enum.map qs.rows, fn row ->
      Enum.zip(cols, row) |> Enum.into(%{})
    end
  end
  defp load_into(qs, model) do
    Enum.map qs.rows, fn(row) ->
      zip    = Enum.zip(qs.columns, row)
      fields = Enum.reduce(zip, %{}, fn({key, value}, map) ->
        Map.put(map, key, value)
      end)

      __MODULE__.load model, fields
    end
  end

end
