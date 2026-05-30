import glimr/db/schema

pub const table_name = "submission_prices_fixed"

pub fn definition() {
  schema.table(table_name, [
    schema.foreign("submission_price_id", "submission_prices")
      |> schema.on_delete(schema.Cascade),
    schema.float("price"),
  ])
}
