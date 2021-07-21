# Documentation

## Summary

Setup notes following [https://dev.to/amencarini/liveview-todomvc-4jin] and [https://github.com/dwyl/phoenix-todo-list-tutorial] with deviations as LiveView and Phoenix has progressed since 2019. My plan is to also possibly move the CSS to Tailwind if applicable.

## Instructions

1. Setup a new Phoenix project with LiveView utilizing binary ids as we do want to persist data: `mix phx.new todo_mvc --module TodoMVC --live --binary-id`
2. Run `mix ecto.setup`, selecting `Y` to install `rebar3` locally.
3. Strip Phoenix banner and Get Started links from `lib/todo_mvc_web/templates/layout/root.html.leex`.
4. Strip footer columns from `lib/todo_mvc_web/live/page_live.html.leex`.
5. Create our `items` entity via the LiveView generator `mix phx.gen.live Todo Item items text:string status:string`.
6. Add entity routes. Note: This requires killing our running server.
   1. In `lib/todo_mvc_web/router.ex` under the section `scope "/", TodoMVCWeb do`:
      ```elixir
      live "/items", ItemLive.Index, :index
      live "/items/new", ItemLive.Index, :new
      live "/items/:id/edit", ItemLive.Index, :edit

      live "/items/:id", ItemLive.Show, :show
      live "/items/:id/show/edit", ItemLive.Show, :edit
      ```
   2. Run `mix phx.server`.

7. Add [OS Data](https://hexdocs.pm/phoenix_live_dashboard/os_mon.html) to LiveDashboard at [http://localhost:4000/dashboard/home]. Note: This requires killing our running server.
   1. In `mix.exs`: `extra_applications: [:logger, :runtime_tools, :os_mon]`
   2. Run `mix phx.server`.
8. Add [Ecto stats](https://hexdocs.pm/phoenix_live_dashboard/ecto_stats.html) to LiveDashboard at [http://localhost:4000/dashboard/home]. Note: This requires killing our running server.
   1. In `mix.exs`: `{:ecto_psql_extras, "~> 0.6"}`
   2. Run `mix deps.get` to get our latest dependency.
   3. In `lib/todo_mvc_web/router.ex`: `live_dashboard "/dashboard", metrics: TodoMVCWeb.Telemetry, ecto_repos: [TodoMVCWeb.Repo]`
   4. Run `mix phx.server`.
9. Following step `Create the TodoMVC UI/UX`
   1. Visit: [http://todomvc.com/examples/vanillajs] add a couple of items to the list.
   2. Inspect the source using your browser's Dev Tools.
   3. Grab the head and body from [https://github.com/tastejs/todomvc/blob/master/examples/vanillajs/index.html] to make it cleaner.
   4. Save as `assets/static/example.html` to have an example with existing items.
10. Add todo mvc css to our assets by running `npm install --prefix assets todomvc-app-css`.
11. Carefully inject [the base of a TodoMVC app](https://github.com/tastejs/todomvc/blob/master/examples/vanillajs/index.html) at the end of `lib/todo_mvc_web/live/item_live/index.html.leex`.
12. Follow along in the section marked [Render Real Data in the TodoMVC Layout](https://github.com/dwyl/phoenix-todo-list-tutorial#4-render-real-data-in-the-todomvc-layout).
13. Follow along in the section marked [In-line the New Item Creation Form](https://github.com/dwyl/phoenix-todo-list-tutorial#5-in-line-the-new-item-creation-form).
    1. We deviate slightly because the form component HTML is located at `lib/todo_mvc_web/live/item_live/form_component.html.leex`.
14. Follow the section marked [Update the `items` Schema to Set `default` Values](https://github.com/dwyl/phoenix-todo-list-tutorial#51-update-the-items-schema-to-set-default-values).
15. Deviate from [Update `index/2` in `ItemController`](https://github.com/dwyl/phoenix-todo-list-tutorial#52-update-index2-in-itemcontroller) as live views don't have controllers.
    1. In `assets/css/phoenix.css`.
       1. Select minified 1st line (ugh) > Right Click > Format Selection. We want this unminified so we can make changes. I've never seen a framework do this and I don't like it at all.
       2. Comment out input styles for `input[type='text']`.
    2. In `assets/css/app.scss`
       1. Restructure CSS to pull in todo mvc css definitions
       2. Add `margin-bottom: 0rem` to remove it on the `header` class.
       3. Add `margin-bottom: 0rem` to remove it on the `#item-form` id, our form.
    3. Rename `FormComponent` to `Form`
    4. In `lib/todo_mvc_web/live/item_live/index.html.leex`
       1. Replace `<input class="new-todo" placeholder="What needs to be done?" autofocus="">` with the line
            ```elixir
            <%= live_component @socket, TodoMVCWeb.ItemLive.Form,
                id: @item.id || :new,
                action: :new,
                item: @item %>
            ```
    5. In `lib/todo_mvc_web/live/item_live/index.ex`
       1. Inside the function `defp apply_action(socket, :index, _params) do`, `|> assign(:item, %Item{})`. We assign an empty item here to satisfy the live component's id property. I'm sure there's a more elegant way around this but it's fine.
    6. We can now use the form to enter a new item, hit enter and we should be able to see it displayed.
16. [Display Count of Items in UI](https://github.com/dwyl/phoenix-todo-list-tutorial#6-display-count-of-items-in-ui)
    1. Test alterations
         ```elixir
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
         ```
    2. Add `remaining_items/1` to `lib/todo_mvc_web/live/item_live/index.ex`.
    3. Add `<%= remaining_items(@items) %>` to HTML, leaving the strong tag that was seemingly stripped.
17. [Toggle a Todo Item's `status` to `completed`](https://github.com/dwyl/phoenix-todo-list-tutorial#7-toggle-a-todo-items-status-to-1)
    1. Add test for 7.1 in `test/todo_mvc_web/live/item_live_test.exs`.
    2. Add function for 7.2 in `lib/todo_mvc_web/live/item_live/index.ex`.
    3. Add route for 7.3 as `live "/items/:id/toggle", ItemLive.Index, :toggle` in `lib/todo_mvc_web/router.ex`.
    4. For 7.4, we tried the checkbox helper from
       1. [https://github.com/toranb/phoenix-live-view-todomvc/blob/master/lib/todo_web/live/component/todo_item.ex]
       2. [https://github.com/dnsbty/live_view_todos/blob/master/lib/live_view_todos_web/live/todo_live.html.leex]
       3. Settled with the input directly via [https://fullstackphoenix.com/tutorials/add-bulk-actions-in-phoenix-liveview] as this more closely matches the existing field. Setting the checked attribute is easier this way, I couldn't figure out a good way to turn it off with the helper.
18. [Edit an Item!](https://github.com/dwyl/phoenix-todo-list-tutorial#8-edit-an-item)
    1. Skip for now as this requires a bit of leg work to deviate correctly, the rest should be pretty straightforward.
19. [Footer Navigation](https://github.com/dwyl/phoenix-todo-list-tutorial#9-footer-navigation)
    1. Add route and filter to index live action.
    2. Create `filter/2` and `selected/2` View Functions but modified to use active/completed vs 0/1.
    3. Deviate in the section `Update the Footer in the index.html Template`.
20. [Clear Completed](https://github.com/dwyl/phoenix-todo-list-tutorial#10-clear-completed)
    1. Deviate to place `clear_completed/0` query in `lib/todo_mvc/todo.ex` as that keeps the Repo usage tidy.
    2. Add a `handle_event` for `clear_completed` in `lib/todo_mvc_web/live/item_live/index.ex`.
    3. Modify both `list_items/0` and `filter/2` in `lib/todo_mvc_web/live/item_live/index.ex`. We want to filter out the new `archived` status, otherwise those tasks will be visible.
         ```elixir
            Enum.filter(Todo.list_items(), fn i -> i.status == "active" || i.status == "completed" end)
         ```
    4. Modify `toggle_status/1` in `lib/todo_mvc_web/live/item_live/index.ex` to add a clause for `archived` to change to `archived`. It's unclear what we should really toggle that to, so we opt for doing nothing.
21. [Pluralise Items Left](https://github.com/dwyl/phoenix-todo-list-tutorial#111-pluralise-items-left)
    1. Place our test in `test/todo_mvc_web/live/item_live_test.exs` changing `ItemView` and item `status`.
    2. Place `pluralize/1` in `lib/todo_mvc_web/live/item_live/index.ex`.
    3. Place the `pluralize(items)` usage in `lib/todo_mvc_web/live/item_live/index.html.leex`.
