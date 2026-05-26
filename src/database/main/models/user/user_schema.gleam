import glimr/db/schema

// docs: https://github.com/glimr-org/glimr?tab=readme-ov-file#migrations

pub const table_name = "users"

pub fn definition() {
  schema.table(table_name, [
    schema.id() |> schema.auto_uuid,
    schema.string("first_name"),
    schema.string("last_name"),
    schema.string("phone") |> schema.nullable(),
    schema.string("email"),
    schema.unix_timestamps(),
  ])
  |> schema.indexes([schema.unique(["email"])])
}
