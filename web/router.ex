defmodule Panglao.Router do
  use Panglao.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/my", Panglao do
    pipe_through :browser # Use the default browser stack

    get "/dashboard", DashboardController, :index
    get "/filer", FilerController, :index
    get "/remote", RemoteController, :index
    get "/multiple", MultipleController, :index
    get "/ads", AdController, :index
    get "/settings", SettingController, :index
    get "/converts", ConvertController, :index
    get "/statistics", StatisticController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Panglao do
  #   pipe_through :api
  # end
end
