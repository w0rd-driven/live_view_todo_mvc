# Day 4 - July 19, 2021

This is a short day as I seemingly took forever to write up the diary and just get started. I spun my wheels a bit trying to figure out the toggle mechanics. I first took a page from the `:edit` event, reusing the patch as `<%= live_patch "", to: Routes.item_index_path(@socket, :toggle, item) %>`. This had a weird side effect of changing the window location. I didn't see the page really change without a refresh though so this seemed wrong. Babies woke up and I finally got tired enough for sleep so the day ended quickly.
