import glimr/db/schema

pub const table_name = "form_price_rates"

pub fn definition() {
  schema.table(table_name, [
    schema.id(),
    schema.foreign("form_price_id", "form_prices")
      |> schema.on_delete(schema.Cascade),
    schema.enum("rate_type", ["single", "monthly", "split"]),
  ])
}
