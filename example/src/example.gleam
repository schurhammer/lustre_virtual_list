import gleam/int
import gleam/list
import lustre
import lustre/attribute.{class}
import lustre/element.{type Element, text}
import lustre/element/html
import lustre/event.{on_click}
import lustre_virtual_list.{virtual_list}

pub fn main() {
  //
  // ⚠️ Important! Register the virtual list component.
  //
  lustre_virtual_list.register()

  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// In this example we keep track of a list of click events.
type Model {
  Model(events: List(String))
}

fn init(_) -> Model {
  Model(events: [])
}

type Msg {
  ItemClick(Int)
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    ItemClick(x) -> {
      let event = "Clicked on Item #" <> int.to_string(x)
      Model(events: [event, ..model.events])
    }
  }
}

fn view(model: Model) -> Element(Msg) {
  element.fragment([
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
    //
    // Create a virtual list of click events!
    //
    virtual_list(
      items: model.events,
      render: fn(event: String) { html.div([class("item")], [text(event)]) },
      item_height: 24,
      item_count: 20,
      attributes: [class("list")],
    ),
  ])
}
