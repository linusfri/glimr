import glimr/db/schema

pub const table_name = "submission_campaigns"

pub fn definition() {
  schema.table(table_name, [
    schema.foreign("submission_id", "agreement_submissions")
      |> schema.on_delete(schema.Cascade),
    schema.string("campaign_id"),
    schema.string("offer_type") |> schema.nullable(),
  ])
}
