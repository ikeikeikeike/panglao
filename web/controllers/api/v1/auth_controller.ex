defmodule Panglao.Api.V1.AuthController do
  use Panglao.Web, :controller

  alias Panglao.{Repo, User, UserFromAuth}

  plug Ueberauth

  def login(%Plug.Conn{assigns: %{ueberauth_auth: %{uid: uid} = auth}} = conn, _params)
        when not is_nil(uid) do
    current_user = Guardian.Plug.current_resource conn

    case UserFromAuth.get_user(struct(auth, provider: :identity), current_user, Repo) do
      {:ok, user} ->
        new_conn      = Guardian.Plug.api_sign_in conn, user
        jwt           = Guardian.Plug.current_token new_conn
        {:ok, claims} = Guardian.Plug.claims new_conn
        exp           = Map.get claims, "exp"
        payload       = %{
          user: user.email,
          token_type: "jwt",
          access_token: jwt,
          expires: exp,
        }

        new_conn
        |> put_resp_header("authorization", "Bearer #{jwt}")
        |> put_resp_header("x-expires", "#{exp}")
        |> json(payload)

      {:error, _changeset} ->
        conn
        |> put_status(401)
        |> text("Unauthorized")
    end
  end
  def login(%Plug.Conn{} = conn, _params) do
    conn
    |> put_status(401)
    |> text("Unauthorized")
  end

end
