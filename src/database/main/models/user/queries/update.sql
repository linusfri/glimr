-- TODO: Add the columns you'd like to update and update 
-- the placeholders

UPDATE users
SET updated_at = $2
WHERE id = $1
RETURNING *
