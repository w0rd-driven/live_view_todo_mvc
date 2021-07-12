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
9. Carefully inject [the base of a TodoMVC app](https://github.com/tastejs/todomvc/blob/master/examples/vanillajs/index.html).
