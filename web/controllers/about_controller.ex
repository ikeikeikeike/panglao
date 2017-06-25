defmodule Panglao.AboutController do
  use Panglao.Web, :controller

  require Logger

  plug :put_layout, "page.html"

  def dmca(%{method: "POST"} = conn, params) do
    with {:ok, %{challenge_ts: isotime}} <- Recaptcha.verify(params["g-recaptcha-response"]),
          :ok <- Panglao.Mails.DMCA.request(params) do
      msg = gettext("We've accepted your report at %{t}", t: isotime)

      conn
      |> put_flash(:info, msg)
      |> redirect(to: about_path(conn, :dmca))
    else error ->
      Logger.error("DMCA: #{inspect(error)}")
      msg = gettext("Something went wrong, there's missing data")

      conn
      |> put_flash(:error, msg)
      |> render("dmca.html")
    end
  end

  def dmca(conn, _params) do
    render conn, "dmca.html"
  end

end
