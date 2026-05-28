INSERT INTO users (email, password, first_name, last_name, created_at, updated_at)
VALUES ($1, $2, $3, $4, EXTRACT(EPOCH FROM NOW())::bigint, EXTRACT(EPOCH FROM NOW())::bigint)
RETURNING *
