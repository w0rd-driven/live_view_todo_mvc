defmodule TodoMVC.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :string
      add :status, :string

      timestamps()
    end

  end
end
