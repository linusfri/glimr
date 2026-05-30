import glimr/db/schema

pub const table_name = "submission_prices"

pub fn definition() {
  schema.table(table_name, [
    schema.id(),
    schema.foreign("submission_id", "agreement_submissions")
      |> schema.on_delete(schema.Cascade),
    schema.enum("price_type", ["fixed", "variable", "mix", "spot"]),
    schema.float("price_addition"),
  ])
}
