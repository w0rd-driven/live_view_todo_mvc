# Documentation

## Summary

Setup notes following [https://dev.to/amencarini/liveview-todomvc-4jin] and [https://github.com/dwyl/phoenix-todo-list-tutorial] with deviations as LiveView and Phoenix has progressed since 2019. My plan is to also possibly move the CSS to Tailwind if applicable.

## Instructions

1. Setup a new Phoenix project with LiveView utilizing binary ids as we do want to persist data: `mix phx.new todo_mvc --module TodoMVC --live --binary-id`
2. Run `mix ecto.setup`, selecting `Y` to install `rebar3` locally.
3. Strip Phoenix banner and Get Started links from `lib/todo_mvc_web/templates/layout/root.html.leex`.
4. Strip footer columns from `lib/todo_mvc_web/live/page_live.html.leex`.
5. Carefully inject [the base of a TodoMVC app](https://github.com/tastejs/todomvc/blob/master/examples/vanillajs/index.html).
6. 