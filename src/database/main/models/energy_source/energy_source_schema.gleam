import glimr/db/schema

pub const table_name = "energy_sources"

pub fn definition() {
  schema.table(table_name, [
    schema.id(),
    schema.foreign("agreement_id", "agreements")
      |> schema.on_delete(schema.Cascade),
    schema.string("label"),
    schema.string("value"),
    schema.float("price"),
  ])
}
