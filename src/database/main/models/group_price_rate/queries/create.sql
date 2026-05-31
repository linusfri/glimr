INSERT INTO group_price_rates (group_price_id, rate_type)
VALUES ($1, $2)
RETURNING *
