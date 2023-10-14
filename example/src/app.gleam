import lustre
import lustre/element/html.{div, p}
import lustre/event.{on_click}
import lustre/element.{text}
import lustre/attribute.{style}
import gleam/list
import gleam/int
import lustre_virtual_list.{on_item_event, virtual_list}

fn render_int(name: Int) {
  html.div(
    [on_click(Click), style([#("height", "100%")])],
    [text("Item #" <> int.to_string(name))],
  )
}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "[data-lustre-app]", Nil)

  Nil
}

fn init(_) {
  0
}

// TODO try to separate the item events from model events

type Msg {
  Click
  ItemClick(Int)
}

fn update(model, msg) {
  case msg {
    Click -> model
    ItemClick(x) -> model + x
  }
}

fn view(model) {
  let count = int.to_string(model)
  div(
    [],
    [
      p([], [text("Click items to add: " <> count)]),
      div(
        [style([#("height", "500px"), #("background", "gray")])],
        [
          list.range(0, 10_000)
          |> virtual_list(
            render_int,
            24,
            30,
            [
              on_item_event(fn(a, b) {
                case b {
                  Click -> ItemClick(a)
                  x -> x
                }
              }),
            ],
          ),
        ],
      ),
    ],
  )
}
