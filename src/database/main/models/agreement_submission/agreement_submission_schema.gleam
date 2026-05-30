import glimr/db/schema

pub const table_name = "agreement_submissions"

pub fn definition() {
  schema.table(table_name, [
    schema.id(),
    schema.foreign("agreement_id", "agreements")
      |> schema.on_delete(schema.Cascade),
    schema.enum("sign_type", [
      "new",
      "resign",
      "move",
      "assigned_price",
      "company",
    ]),
    schema.date("start_date"),
    schema.date("end_date"),
    schema.string("branch") |> schema.nullable(),
    schema.string("energy_source"),
    schema.boolean("exchange_right"),
    schema.boolean("other_supplier"),
    schema.float("yearly_fee"),
    schema.text("notes") |> schema.nullable(),
  ])
}
