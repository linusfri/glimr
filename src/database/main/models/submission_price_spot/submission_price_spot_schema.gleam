import glimr/db/schema

pub const table_name = "submission_prices_spot"

pub fn definition() {
  schema.table(table_name, [
    schema.foreign("submission_price_id", "submission_prices")
      |> schema.on_delete(schema.Cascade),
    schema.float("hourly_price"),
    schema.float("price_variable"),
  ])
}
