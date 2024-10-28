
# Lustre Virtual List

This is a basic virtual list component for rendering very large lists without performance problems.
It renders only a subset of items at a time, based on which items are scrolled into the view.

# How To Use

Before you start your lustre app, register the virtual list component.

```gleam
lustre_virtual_list.register()
```

In your view function, just call the virtual_list to render a virtual list.

```gleam
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

> [!NOTE]
> We recommend only creating virtual lists using the `virtual_list` function, not using the element directly.

1. `items` is a list of items that will be passed to your render function.
2. `render` is a view funciton that receives one item and should return the Element to render.
3. `item_height` you must specify the height of each item so we can calculate the total size of the list.
4. `item_count` specify how many items should be rendered at a time.
5. `attributes` any additional attributes you want to add to the component, for example a class.

## Example

You can run the example in the example folder with the following command.
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
