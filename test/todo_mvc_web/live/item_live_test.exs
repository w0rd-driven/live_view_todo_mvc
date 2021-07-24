defmodule TodoMVCWeb.ItemLiveTest do
  use TodoMVCWeb.ConnCase

  import Phoenix.LiveViewTest

  alias TodoMVC.Todo

  @create_attrs %{status: "active", text: "some text"}
  @update_attrs %{status: "completed", text: "some updated text"}
  @invalid_attrs %{status: nil, text: nil}

  defp fixture(:item) do
    {:ok, item} = Todo.create_item(@create_attrs)
    item
  end

  defp create_item(_) do
    item = fixture(:item)
    %{item: item}
  end

  test "complete/1 returns completed if item.status == 'completed'" do
    assert TodoMVCWeb.ItemLive.Index.complete(%{status: "completed"}) == "completed"
  end

  test "complete/1 returns empty string if item.status == ''" do
    assert TodoMVCWeb.ItemLive.Index.complete(%{status: ""}) == ""
  end

  test "checked/1 returns checked if item.status == 'completed'" do
    assert TodoMVCWeb.ItemLive.Index.checked(%{status: "completed"}) == "checked"
  end

  test "checked/1 returns empty string if item.status == ''" do
    assert TodoMVCWeb.ItemLive.Index.checked(%{status: ""}) == ""
  end

  test "remaining_items/1 returns count of items where item.status=='active'" do
    items = [
      %{text: "one", status: "active"},
      %{text: "two", status: "active"},
      %{text: "done", status: "completed"}
    ]
    assert TodoMVCWeb.ItemLive.Index.remaining_items(items) == 2
  end

  test "remaining_items/1 returns 0 (zero) when no items are status=='active'" do
    items = []
    assert TodoMVCWeb.ItemLive.Index.remaining_items(items) == 0
  end

  test "pluralise/1 returns item for 1 item and items for < 1 <" do
    assert TodoMVCWeb.ItemLive.Index.pluralise([%{text: "one", status: "active"}]) == "item"
    assert TodoMVCWeb.ItemLive.Index.pluralise([
      %{text: "one", status: "active"},
      %{text: "two", status: "active"}
    ]) == "items"
    assert TodoMVCWeb.ItemLive.Index.pluralise([%{text: "one", status: "completed"}]) == "items"
  end

  describe "toggle updates the status of an item 'active' > 'completed' | 'completed' > 'active'" do
    setup [:create_item]

    test "toggle_status/1 item.status 'completed' > 'active'", %{item: item} do
      assert item.status == "active"
      # first toggle
      toggled_item = %{item | status: TodoMVCWeb.ItemLive.Index.toggle_status(item)}
      assert toggled_item.status == "completed"
      # second toggle sets status back to "active"
      assert TodoMVCWeb.ItemLive.Index.toggle_status(toggled_item) == "active"
    end

    test "toggle/2 updates an item.status 'active' > 'completed'", %{conn: conn, item: item} do
      {:ok, _toggle_live, _html} = live(conn, Routes.item_index_path(conn, :toggle, item))

      assert item.status == "active"
      get(conn, Routes.item_index_path(conn, :toggle, item))
      toggled_item = Todo.get_item!(item.id)
      assert toggled_item.status == "completed"
    end
  end
end
