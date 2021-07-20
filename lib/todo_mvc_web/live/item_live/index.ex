defmodule TodoMVCWeb.ItemLive.Index do
  use TodoMVCWeb, :live_view

  alias TodoMVC.Todo
  alias TodoMVC.Todo.Item

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :items, list_items())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Item")
    |> assign(:item, Todo.get_item!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Item")
    |> assign(:item, %Item{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Items")
    |> assign(:item, %Item{})
  end

  defp apply_action(socket, :toggle, %{"id" => id}) do
    item = Todo.get_item!(id)
    Todo.update_item(item, %{status: toggle_status(item)})

    socket
    |> assign(:item, item)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Todo.get_item!(id)
    {:ok, _} = Todo.delete_item(item)

    {:noreply, assign(socket, :items, list_items())}
  end

  defp list_items do
    Todo.list_items()
  end

  # add class "completed" to a list item if item.status = "completed"
  def complete(item) do
    case item.status do
      "completed" -> "completed"
      _ -> "" # empty string means empty class so no style applied
    end
  end

  # add "checked" to input if item.status = "checked"
  def checked(item) do
    case item.status do
      "completed" -> "checked"
      _ -> "" # empty string means empty class so no style applied
    end
  end

  # returns integer value of items where item.status == "completed" (not "done")
  def remaining_items(items) do
    Enum.filter(items, fn i -> i.status == "active" end) |> Enum.count
  end

  def toggle_status(item) do
    case item.status do
      "completed" -> "active"
      "active" -> "completed"
    end
  end
end
