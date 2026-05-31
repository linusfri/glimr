INSERT INTO groups (form_config_id, group_type, title, contract_period_months, yearly_fee, visible_from, visible_until)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *
