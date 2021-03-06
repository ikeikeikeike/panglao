defmodule Panglao.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Panglao.Web, :controller
      use Panglao.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema
      use Chexes.Ecto

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Panglao.Gettext
    end
  end

  def controller do
    quote do
      use Phoenix.Controller
      alias Guardian.Plug.EnsureAuthenticated
      alias Guardian.Plug.EnsurePermissions

      alias Panglao.{Repo, RepoReader}
      import Ecto
      import Ecto.Query

      import Panglao.Router.Helpers
      import Panglao.ErrorHelpers
      import Panglao.Helpers
      import Panglao.Gettext
      import Chexes
    end
  end

  def api do
    quote do
      use Phoenix.Controller

      alias Panglao.{Repo, RepoReader}
      import Ecto
      import Ecto.Query

      import Panglao.Router.Helpers
      import Panglao.Helpers
      import Panglao.Gettext
      import Chexes
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1, action_name: 1]
      import Plug.Conn, only: [put_session: 3, get_session: 2, delete_session: 2, assign: 3]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML
      use Phoenix.HTML.SimplifiedHelpers

      alias Phoenix.{Repo, RepoReader}
      import Ecto.Query

      import Panglao.Router.Helpers
      import Panglao.ErrorHelpers
      import Panglao.Helpers
      import Panglao.Gettext

      import Chexes
      import CommonDeviceDetector.Detector
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Panglao.{Repo, RepoReader}
      import Ecto
      import Ecto.Query
      import Panglao.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
