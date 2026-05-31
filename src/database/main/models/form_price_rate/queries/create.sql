INSERT INTO form_price_rates (form_price_id, rate_type)
VALUES ($1, $2)
RETURNING *
