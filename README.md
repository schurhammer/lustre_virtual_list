
# Work In Progress

This component is still a work in progress. Basic functionality is there, but things may change at any time.

# How To Use

```gleam
//
// Create a virtual list of clickable items!
//
virtual_list(
  items: list.range(1, 100_000),
  render: fn(item: Int) {
    html.div([on_click(ItemClick(item)), class("item")], [
      text("Item #" <> int.to_string(item)),
    ])
  },
  item_height: 24,
  item_count: 40,
  attributes: [class("list")],
),
```

1. `items` is a list of items that will be passed to your `render` function.
2. `render` is a view funciton that receives one item and should return the Element to render.
3. `item_height` you must specify the height of each item so we can calculate the total size of the list.
4. `item_count` specify how many items should be rendered at a time.
5. `attributes` any additional attributes you want to add to the component, for example a class.

Also, you can look at the example project in the `example` folder.

You can run the example with the following command.
```
cd example
gleam run -m lustre/dev start
```

# lustre_virtual_list

[![Package Version](https://img.shields.io/hexpm/v/lustre_virtual_list)](https://hex.pm/packages/lustre_virtual_list)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lustre_virtual_list/)

## Installation

If available on Hex this package can be added to your Gleam project:

```sh
gleam add lustre_virtual_list
```

and its documentation can be found at <https://hexdocs.pm/lustre_virtual_list>.
