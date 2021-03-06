defmodule TodoMVCWeb.ItemLive.Index do
  use TodoMVCWeb, :live_view

  alias TodoMVC.Todo
  alias TodoMVC.Todo.Item

  @impl true
  def mount(_params, _session, socket) do
    uuid = Ecto.UUID.generate()
    items = list_items()
    active_count = Enum.count(filter(items, "active"))
    completed_count = Enum.count(filter(items, "completed"))

    socket = socket
    |> assign(:uuid, uuid)
    |> assign(:item, %Item{})
    |> assign(:filter, "all")
    |> assign(:active_count, active_count)
    |> assign(:completed_count, completed_count)
    |> assign(:editing, %Item{})
    {:ok, assign(socket, :items, items)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    uuid = Ecto.UUID.generate()
    socket
    |> assign(:uuid, uuid)
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
    {:noreply, toggle(socket)}
  end

  def handle_event("toggle_edit", %{"id" => id}, socket) do
    item = Todo.get_item!(id)
    {:noreply, assign(socket, editing: item)}
  end

  def handle_event("toggle_all", %{}, socket) do
    items = list_items()
    for item <- items do
      {:ok, _} = Todo.update_item(item, %{status: toggle_status(item)})
    end

    {:noreply, toggle(socket)}
  end

  def handle_event("filter", %{"filter" => filter}, socket) do
    items = filter(list_items(), filter)

    socket = socket
    |> assign(:items, items)
    |> assign(:filter, filter)
    {:noreply, socket}
  end

  def handle_event("clear_completed", %{}, socket) do
    {:ok, _} = Todo.clear_completed()

    {:noreply, assign(socket, :items, list_items())}
  end

  @impl true
  def handle_info({:blur_text, _params}, socket) do
    item = %Item{}
    {:noreply, assign(socket, editing: item)}
  end

  defp list_items do
    Enum.filter(Todo.list_items(), fn i -> i.status == "active" || i.status == "completed" end)
  end

  # add class "completed" to a list item if item.status = "completed"
  def complete(item) do
    case item.status do
      "completed" -> "completed"
      _ -> "" # empty string means empty class so no style applied
    end
  end

  def editing(editing, item) do
    if editing.id == item.id do
      " editing"
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
      "archived" -> "archived"
    end
  end

  def toggle(socket) do
    items = list_items()
    active_count = Enum.count(filter(items, "active"))
    completed_count = Enum.count(filter(items, "completed"))

    socket
    |> assign(:items, items)
    |> assign(:active_count, active_count)
    |> assign(:completed_count, completed_count)
  end

  def filter(items, str) do
    case str do
      "all" -> Enum.filter(items, fn i -> i.status == "active" || i.status == "completed" end)
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

  # pluralise the word item when the number of items is greather/less than 1
  def pluralise(items) do
    # items where status < 1 is equal to Zero or Greater than One:
    case remaining_items(items) == 0 || remaining_items(items) > 1 do
      true -> "items"
      false -> "item"
    end
  end

  def got_items?(items) do
    items
    |> Enum.count(fn i -> i.status == "active" || i.status == "completed" end) > 0
  end
end
