import lustre/attribute.{class, style}
import lustre/element.{Element, element}
import lustre
import lustre/event
import lustre/effect.{Effect}
import lustre/element/html
import gleam/list
import gleam/dynamic.{Decoder, Dynamic}
import gleam/int
import gleam/io
import gleam/map.{Map}

pub fn virtual_list(
  items: List(a),
  render_item: fn(a) -> Element(msg),
) -> Element(msg) {
  let _ = case
    lustre.is_browser(),
    lustre.is_registered("lustre-virtual-list")
  {
    True, False ->
      lustre.component(
        "lustre-virtual-list",
        init,
        update,
        view,
        on_attribute_change(),
      )
    _, _ -> Ok(Nil)
  }
  let attributes = [
    style([#("display", "block"), #("height", "100%")]),
    attribute.property("slot", Slot(render_item, items)),
  ]
  element("lustre-virtual-list", attributes, [])
}

// TODO we can probably get rid of Slot and just chuck it in Model
type Slot(a, msg) {
  Slot(render: fn(a) -> Element(msg), items: List(a))
}

type Model(a, msg) {
  Model(slot: Slot(a, msg))
}

fn init() {
  let model = Model(slot: Slot(fn(_) { html.div([], []) }, []))
  #(model, effect.none())
}

type Msg(a, msg) {
  OnAttrChange(Attr(a, msg))
  OnInnerMsg(msg)
  OnScroll(Dynamic)
}

type Attr(a, msg) {
  SlotAttr(Slot(a, msg))
}

fn update(
  model: Model(a, msg),
  msg: Msg(a, msg),
) -> #(Model(a, msg), Effect(Msg(a, msg))) {
  case msg {
    OnAttrChange(SlotAttr(slot)) -> #(Model(slot), effect.none())
    OnScroll(dyn) -> {
      io.debug(dyn)
      #(model, effect.none())
    }
    _ -> #(model, effect.none())
  }
}

fn on_attribute_change() -> Map(String, Decoder(Msg(a, msg))) {
  map.new()
  |> map.insert(
    "slot",
    fn(dyn) { Ok(OnAttrChange(SlotAttr(dynamic.unsafe_coerce(dyn)))) },
  )
}

fn view(model: Model(a, msg)) -> Element(Msg(a, msg)) {
  let item_height = 20
  let visible_length = 10
  let scroll = 200
  let scroll_items = scroll / item_height
  let items = model.slot.items
  let items_length = list.length(items)
  let visible =
    items
    |> list.take(visible_length)
  let pad_total = { items_length - visible_length } * item_height
  let pad_top = scroll_items * item_height
  let pad_bottom = pad_total - pad_top
  html.div(
    [
      attribute.class("virtual-container"),
      style([#("height", "100%"), #("overflow", "scroll")]),
      event.on("scroll", fn(dyn) { Ok(OnScroll(dyn)) }),
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
        list.map(
          visible,
          fn(item) {
            html.div(
              [
                class("virtual-item"),
                style([#("height", int.to_string(item_height) <> "px")]),
              ],
              [model.slot.render(item)],
            )
            |> element.map(fn(msg) { OnInnerMsg(msg) })
          },
        ),
      ),
    ],
  )
  // html.div([], [element.text("hello world")])
}
