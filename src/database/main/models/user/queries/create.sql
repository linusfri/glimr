-- TODO: Add the columns you'd like to insert in your preferred 
-- order and update the placeholders

INSERT INTO users (first_name, last_name, phone, email, created_at, updated_at)
VALUES ($1, $2, $3, $4, EXTRACT(EPOCH FROM NOW())::INT, EXTRACT(EPOCH FROM NOW())::INT)
RETURNING *
