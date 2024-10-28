import gleam/dict.{type Dict}
import gleam/dynamic.{type Decoder, type Dynamic}
import gleam/function
import gleam/int
import gleam/list
import gleam/result
import lustre
import lustre/attribute.{type Attribute, class, style}
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/event

/// call this at the beginning of your program to register the virtual list component
pub fn register() {
  let app = lustre.component(init, update, view, on_attribute_change())
  let _ = lustre.register(app, "lustre-virtual-list")
  Nil
}

/// render a virtual list of items
///
/// items: the list of items to virtualise
///
/// render: a function that renders an item
///
/// item_height: you must specify the height of an item
///
/// item_count: you must specify how many items to render at most
///
/// attributes: optional attributes (e.g. styles)
pub fn virtual_list(
  items items: List(a),
  render render_item: fn(a) -> Element(msg),
  item_height item_height: Int,
  item_count item_count: Int,
  attributes attributes: List(Attribute(msg)),
) -> Element(msg) {
  let attributes = [
    style([#("display", "block"), #("height", "100%"), #("min-height", "0")]),
    attribute.property("items", #(items, render_item, item_height, item_count)),
    passthrough_item_event(),
    ..attributes
  ]
  element("lustre-virtual-list", attributes, [])
}

/// handle events on items inside the virtual list to pass them on to the parent
fn passthrough_item_event() -> Attribute(msg) {
  use event <- event.on("item_event")
  event
  |> dynamic.field("detail", fn(x) { Ok(unsafe_coerce(x)) })
  |> result.map(function.identity)
}

type Model(a, msg) {
  Model(
    items: List(a),
    render: fn(a) -> Element(msg),
    item_height: Int,
    item_count: Int,
    scroll_top: Int,
  )
}

fn init(_) {
  let model =
    Model(
      items: [],
      render: fn(_) { html.div([], []) },
      item_height: 0,
      item_count: 0,
      scroll_top: 0,
    )
  #(model, effect.none())
}

type Msg(a, msg) {
  AttrChange(
    items: List(a),
    render: fn(a) -> Element(msg),
    item_height: Int,
    item_count: Int,
  )
  Scroll(Int)
  InnerMsg(msg)
}

fn update(
  model: Model(a, msg),
  msg: Msg(a, msg),
) -> #(Model(a, msg), Effect(Msg(a, msg))) {
  case msg {
    AttrChange(items, render, item_height, item_count) -> #(
      Model(
        ..model,
        items: items,
        render: render,
        item_height: item_height,
        item_count: item_count,
      ),
      effect.none(),
    )
    Scroll(y) -> #(Model(..model, scroll_top: y), effect.none())
    InnerMsg(msg) -> #(model, event.emit("item_event", unsafe_coerce(msg)))
  }
}

fn on_attribute_change() -> Dict(String, Decoder(Msg(a, msg))) {
  dict.new()
  |> dict.insert("items", fn(dyn) {
    use items <- result.try(dynamic.element(0, dynamic.dynamic)(dyn))
    use render <- result.try(dynamic.element(1, dynamic.dynamic)(dyn))
    use item_height <- result.try(dynamic.element(2, dynamic.int)(dyn))
    use item_count <- result.try(dynamic.element(3, dynamic.int)(dyn))
    let items: List(a) = unsafe_coerce(items)
    let render: fn(a) -> Element(msg) = unsafe_coerce(render)
    Ok(AttrChange(items, render, item_height, item_count))
  })
}

fn view(model: Model(a, msg)) -> Element(Msg(a, msg)) {
  case model.item_height {
    0 -> html.div([attribute.class("virtual-container")], [])
    _ -> {
      let item_height = model.item_height
      let visible_length = model.item_count
      let scroll = model.scroll_top
      let scroll_items = scroll / item_height
      let items = model.items
      let items_length = list.length(items)
      let visible =
        items
        |> list.drop(scroll_items)
        |> list.take(visible_length)
      let pad_total = { items_length - visible_length } * item_height
      let pad_top = scroll_items * item_height
      let pad_bottom = pad_total - pad_top
      html.div(
        [
          attribute.class("virtual-container"),
          style([#("height", "100%"), #("overflow-y", "auto")]),
          on_scroll(fn(y) { Scroll(y) }),
        ],
        [
          html.div(
            [
              attribute.class("virtual-viewport"),
              style([
                #("padding-top", int.to_string(pad_top) <> "px"),
                #("padding-bottom", int.to_string(pad_bottom) <> "px"),
              ]),
            ],
            list.map(visible, fn(item) {
              html.div(
                [
                  class("virtual-item"),
                  style([#("height", int.to_string(item_height) <> "px")]),
                ],
                [model.render(item)],
              )
              |> element.map(InnerMsg)
            }),
          ),
        ],
      )
    }
  }
}

fn on_scroll(handle: fn(Int) -> msg) {
  event.on("scroll", fn(dyn) { Ok(handle(get_scroll_y(dyn))) })
}

@external(javascript, "./lustre_virtual_list_ffi.mjs", "getEventScrollY")
fn get_scroll_y(_: Dynamic) -> Int {
  0
}

@internal
pub fn id(x) {
  x
}

@external(erlang, "lustre_virtual_list", "id")
@external(javascript, "./lustre_virtual_list.mjs", "id")
fn unsafe_coerce(value: a) -> b
