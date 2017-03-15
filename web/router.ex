defmodule Panglao.Router do
  use Panglao.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :login_required do
    plug Guardian.Plug.EnsureAuthenticated, handler: Panglao.ErrorController
    plug Panglao.Plug.CurrentUser
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
    pipe_through [:browser, :browser_auth]

    scope "/auth" do
      get "/signup", AuthController, :signup
      get "/logout", AuthController, :logout
      get "/:identity", AuthController, :login
      get "/:identity/callback", AuthController, :callback
      post "/identity/callback", AuthController, :callback
    end
  end

  scope "/my", Panglao do
    pipe_through [:browser, :browser_auth, :login_required] # Use the default browser stack

    get "/", DashboardController, :index
    get "/dashboard", DashboardController, :index
    get "/multiple", MultipleController, :index
    get "/ads", AdController, :index
    get "/settings", SettingController, :index
    get "/converts", ConvertController, :index
    get "/statistics", StatisticController, :index

    scope "/filer" do
      get  "/", FilerController, :index
      post "/upload", FilerController, :upload
    end
    scope "/remote" do
      get  "/", RemoteController, :index
      get  "/progress", RemoteController, :progress
      post "/upload", RemoteController, :upload
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Panglao do
  #   pipe_through :api
  # end
end
