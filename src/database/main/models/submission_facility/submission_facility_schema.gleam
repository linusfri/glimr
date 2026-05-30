import glimr/db/schema

pub const table_name = "submission_facilities"

pub fn definition() {
  schema.table(table_name, [
    schema.foreign("submission_id", "agreement_submissions")
      |> schema.on_delete(schema.Cascade),
    schema.string("facility_id") |> schema.nullable(),
    schema.int("yearly_consumption"),
    schema.string("portfolio") |> schema.nullable(),
  ])
}
