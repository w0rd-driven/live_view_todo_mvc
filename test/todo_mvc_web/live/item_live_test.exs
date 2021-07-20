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

  describe "Index" do
    setup [:create_item]

    test "lists all items", %{conn: conn, item: item} do
      {:ok, _index_live, html} = live(conn, Routes.item_index_path(conn, :index))

      assert html =~ "Listing Items"
      assert html =~ item.status
    end

    test "saves new item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      assert index_live |> element("a", "New Item") |> render_click() =~
               "New Item"

      assert_patch(index_live, Routes.item_index_path(conn, :new))

      assert index_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#item-form", item: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.item_index_path(conn, :index))

      assert html =~ "Item created successfully"
      assert html =~ "some status"
    end

    test "updates item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      assert index_live |> element("#item-#{item.id} a", "Edit") |> render_click() =~
               "Edit Item"

      assert_patch(index_live, Routes.item_index_path(conn, :edit, item))

      assert index_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#item-form", item: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.item_index_path(conn, :index))

      assert html =~ "Item updated successfully"
      assert html =~ "some updated status"
    end

    test "deletes item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      assert index_live |> element("#item-#{item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#item-#{item.id}")
    end
  end

  describe "Show" do
    setup [:create_item]

    test "displays item", %{conn: conn, item: item} do
      {:ok, _show_live, html} = live(conn, Routes.item_show_path(conn, :show, item))

      assert html =~ "Show Item"
      assert html =~ item.status
    end

    test "updates item within modal", %{conn: conn, item: item} do
      {:ok, show_live, _html} = live(conn, Routes.item_show_path(conn, :show, item))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Item"

      assert_patch(show_live, Routes.item_show_path(conn, :edit, item))

      assert show_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#item-form", item: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.item_show_path(conn, :show, item))

      assert html =~ "Item updated successfully"
      assert html =~ "some updated status"
    end
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
