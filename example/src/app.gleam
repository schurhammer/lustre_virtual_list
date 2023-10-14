import lustre
import lustre/element/html
import lustre/element.{Element, text}
import lustre_virtual_list

fn render_name(name: String) -> Element(String) {
  text(name)
}

pub fn main() {
  // TODO something goes wrong when the virtual list is not wrapped in a div - lustre bug?
  let app =
    lustre.element(html.div(
      [],
      [lustre_virtual_list.virtual_list(render_name, ["Tom", "Garfield"])],
    ))
  let assert Ok(_) = lustre.start(app, "[data-lustre-app]", Nil)
  Nil
}
