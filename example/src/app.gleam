import lustre
import lustre/element/html.{div, p}
import lustre/event.{on_click}
import lustre/element.{text}
import lustre/attribute.{class}
import gleam/list
import gleam/int
import gleam/io
import lustre_virtual_list.{virtual_list}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "[data-lustre-app]", Nil)

  Nil
}

fn init(_) {
  0
}

type Msg {
  ItemClick(Int)
}

fn update(model, msg) {
  io.debug(msg)
  case msg {
    ItemClick(x) -> model + x
  }
}

fn view(model) {
  let count = int.to_string(model)
  div(
    [],
    [
      p([], [text("Click items to add: " <> count)]),
      //
      // create the virtual list!
      //
      virtual_list(
        items: list.range(0, 100_000),
        render: fn(item: Int) {
          html.div(
            [on_click(ItemClick(item)), class("item")],
            [text("Item #" <> int.to_string(item))],
          )
        },
        item_height: 24,
        item_count: 30,
        attributes: [class("list")],
      ),
      p([], [text("Version 3")]),
    ],
  )
}
