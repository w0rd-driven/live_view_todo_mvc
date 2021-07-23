# Day 7 - July 22, 2021

I started the day looking to add the `blur_text` implementation from [https://github.com/toranb/phoenix-live-view-todomvc/blob/master/lib/todo_web/live/component/todo_item.ex]. It was a great opportunity to learn about sending messages as I took a cue from [https://elixirforum.com/t/nested-livecomponents-how-to-send-message-to-parent-via-top/31915/9] though I thought PubSub was overkill if LiveView components can talk between parent and child.

Implementing the double click behavior was pretty straightforward using [Edit an Item!](https://github.com/dwyl/phoenix-todo-list-tutorial#8-edit-an-item). It looks like the span covers the link then when it's active goes left -9999px to jump out of the way. That's pretty brilliant and not something I would've thought of without seeing it.

I believe the final extra credit piece and what should hopefully wrap this up is to set the cursor to the end of the line on editing. Following a lead from [https://dev.to/amencarini/liveview-todomvc-part-2-params-and-hooks-2l5] this was a good introduction to hooks in LiveView. The JavaScript function `setSelectionRange` is our star here as we can use it to focus on the text input and jump to the end of the line as we see In the [Vue.js example](https://todomvc.com/examples/vue/).

The final piece now that I think of it, will be to clean up our tests. It would be useful to start from scratch to see if I could come up with a streamlined implementation that combined all of the tutorials. I feel like this covered quite a good bit of what LiveView can do though.
