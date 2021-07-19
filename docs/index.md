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
15. Starting to deviate from [Update `index/2` in `ItemController`](https://github.com/dwyl/phoenix-todo-list-tutorial#52-update-index2-in-itemcontroller) as live views don't have controllers.
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