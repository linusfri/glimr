INSERT INTO form_prices (form_config_id, signable_from, signable_until, is_best_value)
VALUES ($1, $2, $3, $4)
RETURNING *
