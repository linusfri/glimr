import glimr/db/schema

pub const table_name = "form_configs_spot"

pub fn definition() {
  schema.table(table_name, [
    schema.foreign("form_config_id", "form_configs")
      |> schema.on_delete(schema.Cascade),
    schema.float("yearly_fee"),
    schema.float("variable_costs"),
    schema.float("surcharge"),
  ])
}
