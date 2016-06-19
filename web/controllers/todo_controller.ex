defmodule Todo.TodoController do
  use Todo.Web, :controller

  alias Todo.Todo

  plug :scrub_params, "todo" when action in [:create, :update]

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    todos = Repo.all(my_todos(user))
    render(conn, "index.html", todos: todos)
  end
  #        logged_in_user = Guardian.Plug.current_resource(conn)

  def new(conn, _params) do
    changeset = Guardian.Plug.current_resource(conn)
    |> build_assoc(:todos)
    |> Todo.changeset()

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"todo" => todo_params}) do
    changeset = Guardian.Plug.current_resource(conn)
    |> build_assoc(:todos)
    |> Todo.changeset(todo_params)

    case Repo.insert(changeset) do
      {:ok, _todo} ->
        conn
        |> put_flash(:info, "Todo created successfully.")
        |> redirect(to: todo_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    todo = Repo.get!(my_todos(user), id)
    render(conn, "show.html", todo: todo)
  end

  def edit(conn, %{"id" => id}) do
    todo = Repo.get!(Todo, id)
    changeset = Todo.changeset(todo)
    render(conn, "edit.html", todo: todo, changeset: changeset)
  end

  def update(conn, %{"id" => id, "todo" => todo_params}) do
    todo = Repo.get!(Todo, id)
    changeset = Todo.changeset(todo, todo_params)

    case Repo.update(changeset) do
      {:ok, todo} ->
        conn
        |> put_flash(:info, "Todo updated successfully.")
        |> redirect(to: todo_path(conn, :show, todo))
      {:error, changeset} ->
        render(conn, "edit.html", todo: todo, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    todo = Repo.get!(Todo, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(todo)

    conn
    |> put_flash(:info, "Todo deleted successfully.")
    |> redirect(to: todo_path(conn, :index))
  end

  def complete_todo(conn, %{"id" => id}) do
    changeset = Repo.get!(Todo, id)
    changeset = Ecto.Changeset.change changeset, completed: true

    case Repo.update(changeset) do
      {:ok, todo} ->
        conn
        |> put_flash(:info, "Todo marked as completed")
        |> redirect(to: todo_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:info, "Oops, something went wrong")
        |> redirect(to: todo_path(conn, :index))
    end
  end


  defp my_todos(user) do
    assoc(user, :todos)
  end
end
