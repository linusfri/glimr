import glimr/db/schema

pub const table_name = "group_price_rates"

pub fn definition() {
  schema.table(table_name, [
    schema.id(),
    schema.foreign("group_price_id", "group_prices")
      |> schema.on_delete(schema.Cascade),
    schema.enum("rate_type", ["single", "monthly", "split"]),
  ])
}
