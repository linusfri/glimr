import glimr/db/schema

pub const table_name = "form_prices"

pub fn definition() {
  schema.table(table_name, [
    schema.id(),
    schema.foreign("form_config_id", "form_configs")
      |> schema.on_delete(schema.Cascade),
    schema.date("signable_from"),
    schema.date("signable_until"),
    schema.boolean("is_best_value") |> schema.default_bool(False),
  ])
}
