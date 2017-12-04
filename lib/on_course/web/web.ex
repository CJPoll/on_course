defmodule OnCourse.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use OnCourse.Web, :controller
      use OnCourse.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: OnCourse.Web
      import Plug.Conn
      import OnCourse.Web.Router.Helpers
      alias OnCourse.Web.Router.Helpers, as: Path
      import OnCourse.Web.Gettext
      alias OnCourse.Web.ErrorView
      alias OnCourse.Accounts
      alias OnCourse.Accounts.User
      alias OnCourse.Web.Endpoint
      alias OnCourse.Permission
      alias OnCourse.Repo
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/on_course/web/templates",
                        namespace: OnCourse.Web

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import OnCourse.Web.Router.Helpers
      import OnCourse.Web.ErrorHelpers
      import OnCourse.Web.Gettext

      alias OnCourse.Permission

      def csrf_token(%Plug.Conn{} = conn) do
        Plug.CSRFProtection.get_csrf_token()
      end
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import OnCourse.Web.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
