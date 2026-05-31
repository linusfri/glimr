INSERT INTO form_configs (agreement_id, form_type)
VALUES ($1, $2)
RETURNING *
