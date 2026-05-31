import glimr/db/schema

pub const table_name = "form_price_rates_monthly"

pub fn definition() {
  schema.table(table_name, [
    schema.foreign("form_price_rate_id", "form_price_rates")
      |> schema.on_delete(schema.Cascade),
    schema.float("rate"),
    schema.date("valid_month"),
  ])
}
