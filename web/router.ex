defmodule Panglao.Router do
  use Panglao.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :embedable do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Panglao do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/l/:id/:slug", PageController, :short
    get "/link/:id/:name", PageController, :direct
    get "/splash", PageController, :splash
  end

  scope "/", Panglao do
    pipe_through :embedable # Use the default browser stack

    get "/embed/:id/:name", PageController, :embed
  end

  scope "/my", Panglao do
    pipe_through :browser # Use the default browser stack

    get "/dashboard", DashboardController, :index
    get "/remote", RemoteController, :index
    get "/filer", FilerController, :index
    get "/multiple", MultipleController, :index
    get "/ads", AdController, :index
    get "/settings", SettingController, :index
    get "/converts", ConvertController, :index
    get "/statistics", StatisticController, :index

    scope "/filer" do
      post "/upload", FilerController, :upload
    end
    scope "/remote" do
      post "/upload", RemoteController, :upload
    end

  end

  # Other scopes may use custom stacks.
  # scope "/api", Panglao do
  #   pipe_through :api
  # end
end
