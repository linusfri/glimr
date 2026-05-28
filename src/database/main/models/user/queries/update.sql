UPDATE users
SET email = $2, password = $3, first_name = $4, last_name = $5, updated_at = $6
WHERE id = $1
RETURNING *
