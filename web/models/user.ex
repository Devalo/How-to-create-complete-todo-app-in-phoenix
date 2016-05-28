defmodule Todo.User do
  use Todo.Web, :model

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps
  end

   def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(email), [])
    |> validate_length(:password, min: 6)
    |> validate_format(:email, ~r/@/)
  end
end
