# Instructions

These are the steps taken to complete the tutorial from start to finish. My intention was to leave breadcrumbs for anyone else to do this again in the future.

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
    1. Comment out `label`, `button` and `form` sections in `assets/css/phoenix.css` that deal with margins.
    2. In `lib/todo_mvc_web/live/item_live/form.html.leex` change the form to have a class of `item-form` with an id of `item-form-#{@item.id}` to make the id unique. This form may appear at least twice so it needs to be differentiated.
    3. In `lib/todo_mvc_web/live/item_live/index.ex`
       1. Add `|> assign(:editing, %Item{})` to index `apply_action` function to assign `@editing` on page load.
       2. Add `toggle_edit` event as

            ```elixir
            def handle_event("toggle_edit", %{"id" => id}, socket) do
               item = Todo.get_item!(id)
               {:noreply, assign(socket, editing: item)}
            end
            ```

       3. Add `editing/2` function as

            ```elixir
            def editing(editing, item) do
               if editing.id == item.id do
                  " editing"
               end
            end
            ```

    4. In `lib/todo_mvc_web/live/item_live/index.html.leex`
       1. Add `<%= editing(@editing, item) %>` to `.todo-list li` element.
       2. Change the label inner text to `<%= link item.text, to: "#", phx_click: "toggle_edit", phx_value_id: item.id %>` to add our edit link.
       3. Below the `div .view` element add a conditional form render

            ```elixir
            <%= if item.id == @editing.id do %>
               <%= live_component @socket, TodoMVCWeb.ItemLive.Form,
                  id: item.id,
                  class: "edit",
                  action: :edit,
                  item: item,
                  return_to: Routes.item_index_path(@socket, :index) %>
            <% end %>
            ```

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
22. [Hide Footer When There Are Zero Items](https://github.com/dwyl/phoenix-todo-list-tutorial#112-hide-footer-when-there-are-zero-items).
    1. Place `got_items?/1` in `lib/todo_mvc_web/live/item_live/index.ex` as `Enum.count` can skip the filter step.

         ```elixir
         def got_items?(items) do
            items
            |> Enum.count(fn i -> i.status == "active" || i.status == "completed" end) > 0
         end
         ```

    2. Wrap the footer element in `<%= if got_items?(@items) do %>` in `lib/todo_mvc_web/live/item_live/index.html.leex`.
23. [Route `/` to `ItemController.index/2`](https://github.com/dwyl/phoenix-todo-list-tutorial#113-route--to-itemcontrollerindex2)
    1. In `lib/todo_mvc_web/router.ex`, modify the default route as `live "/", ItemLive.Index, :index`
24. [Add Turbolinks to Eliminate Page Refresh](https://github.com/dwyl/phoenix-todo-list-tutorial#114-add-turbolinks-to-eliminate-page-refresh)
    1. Turns out we don't need this because we're using LiveView. The page already refreshes without a reload.
25. Extra credit
    1. Fix toggle all checkbox
       1. In `lib/todo_mvc_web/live/item_live/index.html.leex` change `toggle-all` element to `<input id="toggle-all" class="toggle-all" type="checkbox" phx-click="toggle_all" >`.
       2. In `lib/todo_mvc_web/live/item_live/index.ex`
          1. Add `toggle_all` event that gets our list and iterates through, calling toggle on each.
          2. Refactor both `toggle` and `toggle_all` event to use a `toggle` function that gets the filtered list and assigns the counts to the socket.
    2. Add `blur_text` event in Form component to disable editing when click out occurs.
       1. In `lib/todo_mvc_web/live/item_live/index.ex` add `handle_info/2`

            ```elixir
            @impl true
            def handle_info({:blur_text, _params}, socket) do
               item = %Item{}
               {:noreply, assign(socket, editing: item)}
            end
            ```

       2. In `lib/todo_mvc_web/live/item_live/form.html.leex` add `, phx_blur: :blur_text, phx_target: @myself` to the `text_input` helper.
       3. In `lib/todo_mvc_web/live/item_live/form.ex` add `handle_event/3`

            ```elixir
            def handle_event("blur_text", _params, socket) do
               send self(), {:blur_text, %{}}
               {:noreply, socket}
            end
            ```

    3. Add `double-click` behavior from [Edit an Item!](https://github.com/dwyl/phoenix-todo-list-tutorial#8-edit-an-item)
       1. Add css to `assets/css/app.scss` but using the word `double-click` instead of abbreviated.
       2. In `lib/todo_mvc_web/live/item_live/index.html.leex` change label link helper to add a blank span afterward. This needs to be a sibbling to work.
    4. Add focus hook outlined in [https://dev.to/amencarini/liveview-todomvc-part-2-params-and-hooks-2l5] as we need to set focus when the edit form is shown.
       1. In `lib/todo_mvc_web/live/item_live/index.html.leex`, change the item li to `<li id="item-<%= item.id %>" data-id="<%= item.id %>" class="<%= complete(item) %><%= editing(@editing, item) %>" phx-hook="Item">`
          1. This adds our Item hook and generates a unique dom id, required by hooks or you'll see a console message `phoenix_live_view.js?2c90:1 no DOM ID for hook "Item". Hooks require a unique ID on each element. <li data-id=​"83c18ff1-c0ad-42fb-bbca-2dca1598a923" class=​"completed" phx-hook=​"Item">​…​</li>`
       2. Add the hook from the url in `assets/js/app.js` before our `let liveSocket` initialization.
       3. Change the `liveSocket` line to as we wish to keep our csrfToken params.

            ```js
            let liveSocket = new LiveSocket("/live", Socket, {
            params: {_csrf_token: csrfToken},
            hooks: hooks
            })
            ```
