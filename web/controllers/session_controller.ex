defmodule Todo.SessionController do
  use Todo.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => user, "password" => pass}}) do
    case Todo.Auth.login_by_email_and_pass(conn, user, pass, repo: Repo) do
      {:ok, conn} ->
        logged_in_user = Guardian.Plug.current_resource(conn)
        conn
        |> put_flash(:info, "Innlogget")
        |> redirect(to: todo_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Feil brukernavn/passord")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Guardian.Plug.sign_out
    |> put_flash(:info, "Logget ut")
    |> redirect(to: "/")
  end
end

