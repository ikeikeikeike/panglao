defmodule Panglao.Router do
  use Panglao.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug RemoteIp
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :browser_required do
    plug Guardian.Plug.EnsureAuthenticated, handler: Panglao.ErrorController
    plug Panglao.Plug.CurrentUser
  end

  pipeline :embedable do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug RemoteIp
  end

  pipeline :api do
    plug :accepts, ["json", "image", "html"]
    plug RemoteIp
  end

  pipeline :api_auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  pipeline :api_required do
    plug Guardian.Plug.EnsureAuthenticated, handler: Panglao.Api.ErrorController
    plug Panglao.Plug.CurrentUser
  end

  scope "/", Panglao do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/l/:id/:slug", PageController, :short
    get "/link/:id/:name", PageController, :direct
    # get "/splash", PageController, :splash
  end

  scope "/-", Panglao do
    pipe_through :browser # Use the default browser stack

    get "/policy", AboutController, :policy
    get "/terms", AboutController, :terms
    get "/contact", AboutController, :contact
    get "/dmca", AboutController, :dmca
    post "/dmca", AboutController, :dmca
  end

  scope "/", Panglao do
    pipe_through :embedable # Use the default browser stack

    get "/embed/:id/:name", PageController, :embed
  end

  scope "/", Panglao do
    pipe_through :embedable # Use the default browser stack

    get "/unavailable", ErrorController, :unavailable
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
    pipe_through [:browser, :browser_auth, :browser_required] # Use the default browser stack

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

  # TODO: These endpoints have to port to Golang system or OpenResty(Redis) system someday.

  scope "/1", Panglao.Api.V1, as: "api_v1" do
    pipe_through [:api]

    scope "/auth" do
      post "/login", AuthController, :login
    end
  end

  scope "/1", Panglao.Api.V1, as: "api_v1" do
    pipe_through [:api, :api_auth]

    scope "/user" do
      pipe_through [:api_required]

      get "/info", UserController, :info
    end

    scope "/object" do
      pipe_through [:api_required]

      get "/link", ObjectController, :link
      get "/info", ObjectController, :info
      get "/alive", ObjectController, :alive
      get "/rename", ObjectController, :rename
      get "/upload", ObjectController, :upload
      get "/splash", ObjectController, :splash
    end

    scope "/remote" do
      pipe_through [:api_required]

      get "/upload", RemoteController, :upload
      get "/status", RemoteController, :status
    end
  end

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

  # Other scopes may use custom stacks.
  # scope "/api", Panglao do
  #   pipe_through :api
  # end
end
