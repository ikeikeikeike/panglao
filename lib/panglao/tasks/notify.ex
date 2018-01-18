defmodule Panglao.Tasks.Notify do
  alias Panglao.RepoReader, as: Repo

  def perform do
    summarize()
  end

  def summarize do
    object()
  end

  def object do
    objects =
      Repo.execute_and_load("""
      select count(*) as objects from objects
      """, [])

    none =
      Repo.execute_and_load("""
      select count(*) as nones from objects where stat = 'NONE'
      """, [])

    remote =
      Repo.execute_and_load("""
      select count(*) as remotes from objects where stat = 'REMOTE'
      """, [])

    download =
      Repo.execute_and_load("""
      select count(*) as downloads from objects where stat = 'DOWNLOAD'
      """, [])

    crap =
      Repo.execute_and_load("""
      select count(*) as craps from objects where stat = 'CRAP'
      """, [])

    wrong =
      Repo.execute_and_load("""
      select count(*) as wrongs from objects where stat = 'WRONG'
      """, [])

    pending =
      Repo.execute_and_load("""
      select count(*) as pendings from objects where stat = 'PENDING'
      """, [])

    started =
      Repo.execute_and_load("""
      select count(*) as starteds from objects where stat = 'STARTED'
      """, [])

    failure =
      Repo.execute_and_load("""
      select count(*) as failures from objects where stat = 'FAILURE'
      """, [])

    success =
      Repo.execute_and_load("""
      select count(*) as successes from objects where stat = 'SUCCESS'
      """, [])

    removed =
      Repo.execute_and_load("""
      select count(*) as removeds from objects where stat = 'REMOVED'
      """, [])

    elems =
      objects ++ none ++ remote ++ download ++ crap ++ wrong ++
      pending ++ started ++ failure ++ success ++ removed

    format(elems)
    |> send_slack("OBJECT")
  end

  defp format(records) do
    formated =
      Enum.map records, fn record ->
        Enum.map(record, fn {k, v} -> "#{k}\t#{v}" end)
        |> Enum.join("\t")
      end

    Enum.join(formated, "\n")
  end

  @webhook_url Application.get_env(:panglao, :slack)[:webhook]
  defp send_slack(io, name) do
    params = %{
      link_names: 1,
      channel: "#alert_panglao",
      username: "Summaries",
      text: "------ #{name} ------\n" <> io,
    }
    HTTPoison.post @webhook_url, Poison.encode!(params), [{"Content-Type", "application/json"}]
  end

end
