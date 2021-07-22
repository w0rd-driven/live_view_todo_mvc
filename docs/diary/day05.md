# Day 5 - July 20, 2021

I finished the toggle UI portion finally by settling on making my own input over the checkbox helper. I took a play from [https://github.com/toranb/phoenix-live-view-todomvc/blob/master/lib/todo_web/live/component/todo_item.ex] and tried the checkbox helper but I couldn't easily get the same behavior. I also tried the helper from [https://github.com/dnsbty/live_view_todos/blob/master/lib/live_view_todos_web/live/todo_live.html.leex] as more examples always help my understanding but neither got to the end result I wanted.

I figured out how to use interpolation for a class like `class: "toggle #{checked(item)}"` from [https://elixirforum.com/t/checkboxes-as-lists-of-ids-common-case/29293] but I failed to realize the checked class doesn't matter here, the checked attribute is what is set in CSS.

I skipped editing as that was taking too long to start while filtering proved a little easier. Skipping was the best thing to do as I knocked out the rest of the tutorial and added a small piece of flare.
