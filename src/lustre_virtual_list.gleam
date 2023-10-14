import lustre/attribute.{class, style}
import lustre/element.{Element, element}
import lustre
import lustre/effect.{Effect}
import lustre/element/html
import gleam/list
import gleam/dynamic.{Decoder}
import gleam/int
import gleam/io
import gleam/map.{Map}

pub fn virtual_list(
  render_item: fn(a) -> Element(msg),
  items: List(a),
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
  let attributes = [attribute.property("slot", Slot(render_item, items))]
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
  io.debug("view model")
  io.debug(model)
  html.div(
    [class("virtual-list")],
    [
      html.div(
        [
          attribute.class("virtual-view"),
          style([
            #("padding-top", int.to_string(0)),
            #("padding-bottom", int.to_string(0)),
          ]),
        ],
        list.map(
          model.slot.items,
          fn(item) {
            html.div([class("virtual-item")], [model.slot.render(item)])
            |> element.map(fn(msg) { OnInnerMsg(msg) })
          },
        ),
      ),
    ],
  )
  // html.div([], [element.text("hello world")])
}
