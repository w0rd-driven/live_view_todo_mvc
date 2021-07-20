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
    uuid = Ecto.UUID.generate()
    items = list_items()
    active_count = Enum.count(filter(items, "active"))
    completed_count = Enum.count(filter(items, "completed"))

    socket
    |> assign(:page_title, "Listing Items")
    |> assign(:uuid, uuid)
    |> assign(:item, %Item{})
    |> assign(:filter, "all")
    |> assign(:active_count, active_count)
    |> assign(:completed_count, completed_count)
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

  def handle_event("toggle", %{"id" => id}, socket) do
    item = Todo.get_item!(id)
    {:ok, _} = Todo.update_item(item, %{status: toggle_status(item)})
    items = list_items()
    active_count = Enum.count(filter(items, "active"))
    completed_count = Enum.count(filter(items, "completed"))

    socket = socket
    |> assign(:items, items)
    |> assign(:active_count, active_count)
    |> assign(:completed_count, completed_count)
    {:noreply, socket}
  end

  def handle_event("filter", %{"filter" => filter}, socket) do
    items = filter(list_items(), filter)

    socket = socket
    |> assign(:items, items)
    |> assign(:filter, filter)
    {:noreply, socket}
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

  def filter(items, str) do
    case str do
      "all" -> items
      "active" -> Enum.filter(items, fn i -> i.status == "active" end)
      "completed" -> Enum.filter(items, fn i -> i.status == "completed" end)
    end
  end

  def selected(filter, str) do
    case filter == str do
      true -> "selected"
      false -> ""
    end
  end
end
