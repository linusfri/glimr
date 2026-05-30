import glimr/db/schema

pub const table_name = "groups"

pub fn definition() {
  schema.table(table_name, [
    schema.id(),
    schema.foreign("form_config_id", "form_configs")
      |> schema.on_delete(schema.Cascade),
    schema.enum("group_type", ["fixed", "mix"]),
    schema.string("title"),
    schema.int("contract_period_months"),
    schema.float("yearly_fee"),
    schema.timestamp("visible_from"),
    schema.timestamp("visible_until"),
  ])
}
