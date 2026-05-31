import glimr/db/schema

pub const table_name = "group_price_rates_split"

pub fn definition() {
  schema.table(table_name, [
    schema.foreign("group_price_rate_id", "group_price_rates")
      |> schema.on_delete(schema.Cascade),
    schema.float("fixed_rate"),
    schema.float("variable_rate"),
    schema.date("valid_month"),
  ])
}
