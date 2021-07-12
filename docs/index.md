# Documentation

## Summary

Setup notes following [https://dev.to/amencarini/liveview-todomvc-4jin] with deviations as LiveView and Phoenix has progressed since 2019. My plan is to also possibly move the CSS to Tailwind if applicable.

## Instructions

1. Setup a new Phoenix project with LiveView utilizing binary ids as we do want to persist data: `mix phx.new todo_mvc --module TodoMVC --live --binary-id`
2. Run `mix ecto.setup`, selecting `Y` to install `rebar3` locally.
3. Strip Phoenix banner and Get Started links from `lib/todo_mvc_web/templates/layout/root.html.leex`.
