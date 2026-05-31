import glimr/db/schema

pub const table_name = "form_configs"

pub fn definition() {
  schema.table(table_name, [
    schema.id(),
    schema.enum("form_type", [
      "fixed",
      "variable",
      "mix",
      "spot",
      "winter_security",
    ]),
  ])
  |> schema.indexes([schema.unique(["form_type"])])
}
