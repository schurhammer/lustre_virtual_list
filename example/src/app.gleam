import lustre
import lustre/element/html
import lustre/element.{text}
import lustre_virtual_list
import lustre/attribute.{style}
import gleam/list
import gleam/int

fn render_int(name: Int) {
  text("Item #" <> int.to_string(name))
}

pub fn main() {
  let app =
    lustre.element(html.div(
      [style([#("height", "500px"), #("background", "gray")])],
      [
        list.range(0, 1000)
        |> lustre_virtual_list.virtual_list(render_int),
      ],
    ))
  let assert Ok(_) = lustre.start(app, "[data-lustre-app]", Nil)
  Nil
}
