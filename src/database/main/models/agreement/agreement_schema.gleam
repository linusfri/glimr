import glimr/db/schema

pub const table_name = "agreements"

pub fn definition() {
  schema.table(table_name, [
    schema.id(),
    schema.enum("sign_type", [
      "new",
      "resign",
      "move",
      "assigned_price",
      "company",
    ]),
    schema.float("vat_percent"),
    schema.string("title") |> schema.nullable(),
    schema.text("description") |> schema.nullable(),
  ])
}
