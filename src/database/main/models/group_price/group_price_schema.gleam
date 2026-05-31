import glimr/db/schema

pub const table_name = "group_prices"

pub fn definition() {
  schema.table(table_name, [
    schema.id(),
    schema.foreign("group_id", "groups")
      |> schema.on_delete(schema.Cascade),
    schema.unix_timestamp("signable_from"),
    schema.unix_timestamp("signable_until"),
    schema.boolean("is_best_value") |> schema.default_bool(False),
  ])
}
