INSERT INTO group_prices (group_id, signable_from, signable_until, is_best_value)
VALUES ($1, $2, $3, $4)
RETURNING *
