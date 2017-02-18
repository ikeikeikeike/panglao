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

  scope "/", Panglao do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/my", Panglao do
    pipe_through :browser # Use the default browser stack

    get "/dashboard", DashboardController, :index
    get "/remote", RemoteController, :index
    get "/multiple", MultipleController, :index
    get "/ads", AdController, :index
    get "/settings", SettingController, :index
    get "/converts", ConvertController, :index
    get "/statistics", StatisticController, :index

    scope "/filer" do
      get "/", FilerController, :index
      post "/upload", FilerController, :upload
    end

  end

  # Other scopes may use custom stacks.
  # scope "/api", Panglao do
  #   pipe_through :api
  # end
end
