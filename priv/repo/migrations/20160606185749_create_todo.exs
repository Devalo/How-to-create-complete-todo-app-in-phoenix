defmodule Todo.Repo.Migrations.CreateTodo do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string
      add :completed, :boolean, default: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:todos, [:user_id])

  end
end
