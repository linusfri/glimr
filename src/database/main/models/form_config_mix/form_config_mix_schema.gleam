import glimr/db/schema

pub const table_name = "form_configs_mix"

pub fn definition() {
  schema.table(table_name, [
    schema.foreign("form_config_id", "form_configs")
      |> schema.on_delete(schema.Cascade),
    schema.float("variable_costs"),
  ])
}
