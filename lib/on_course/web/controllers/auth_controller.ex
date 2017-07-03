defmodule OnCourse.Web.Auth.Controller do
  use OnCourse.Web, :controller

  @type ignored :: term

  @spec request(Plug.Conn.t, ignored) :: Plug.Conn.t
  def request(%Plug.Conn{} = conn, _params) do
    conn
  end

  @spec callback(Plug.Conn.t, ignored) :: Plug.Conn.t
  def callback(%Plug.Conn{assigns: %{ueberauth_auth: %{info: info}}} = conn, _params) do
    email = info.email
    handle = info.nickname
    avatar = info.urls.avatar_url

    data =
      %{
        email: email,
        handle: handle,
        avatar: avatar
      }

    with {:ok, %User{} = user} <- Accounts.upsert_user(%User{}, data |> IO.inspect) do
      conn
      |> Guardian.Plug.sign_in(user)
      |> redirect(to: page_path(Endpoint, :dashboard))
    else
      {:error, cs} -> send_resp(conn, 500, "Update failed: #{inspect cs.errors}")
      _ -> send_resp(conn, 500, "Not sure what happened here ¯\_(ツ)_/¯")
    end
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_failure: %{errors: errs}}} = conn, _params) do
    conn |> send_resp(400, "#{inspect errs}")
  end
end
