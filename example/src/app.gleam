import lustre
import lustre/element/html.{div, p}
import lustre/event.{on_click}
import lustre/element.{text}
import lustre/attribute.{class}
import gleam/list
import gleam/int
import gleam/io
import lustre_virtual_list.{virtual_list}

fn render_int(num: Int) {
  html.div(
    [on_click(ItemClick(num)), class("item")],
    [text("Item #" <> int.to_string(num))],
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
      list.range(0, 10_000)
      |> virtual_list(render_int, 24, 30, [class("list")]),
      p([], [text("Version 2")]),
    ],
  )
}
