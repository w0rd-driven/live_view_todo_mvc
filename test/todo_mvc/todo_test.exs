defmodule TodoMVC.TodoTest do
  use TodoMVC.DataCase

  alias TodoMVC.Todo

  describe "items" do
    alias TodoMVC.Todo.Item

    @valid_attrs %{status: "some status", text: "some text"}
    @update_attrs %{status: "some updated status", text: "some updated text"}
    @invalid_attrs %{status: nil, text: nil}

    def item_fixture(attrs \\ %{}) do
      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Todo.create_item()

      item
    end

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Todo.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Todo.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Todo.create_item(@valid_attrs)
      assert item.status == "some status"
      assert item.text == "some text"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todo.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, %Item{} = item} = Todo.update_item(item, @update_attrs)
      assert item.status == "some updated status"
      assert item.text == "some updated text"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Todo.update_item(item, @invalid_attrs)
      assert item == Todo.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Todo.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Todo.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Todo.change_item(item)
    end
  end
end
