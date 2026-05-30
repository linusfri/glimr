import glimr/db/schema

pub const table_name = "groups_mix"

pub fn definition() {
  schema.table(table_name, [
    schema.foreign("group_id", "groups")
      |> schema.on_delete(schema.Cascade),
    schema.float("fixed_percent"),
  ])
}
