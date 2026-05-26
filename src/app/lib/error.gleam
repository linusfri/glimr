import gleam/json
import glimr/db/db
import glimr/http/response.{type Response}

pub fn db_error_to_response(db_error: db.DbError) -> Response {
  case db_error {
    db.NotFound ->
      json.object([#("error", json.string("Not found"))])
      |> response.json(404)

    db.ConstraintError(constraint: c, message: _) ->
      json.object([
        #("error", json.string("Conflict")),
        #("constraint", json.string(c)),
      ])
      |> response.json(409)

    db.QueryError(message: m) ->
      json.object([#("error", json.string(m))])
      |> response.json(422)

    db.ConnectionError(message: _)
    | db.TimeoutError
    | db.ConfigError(message: _) ->
      json.object([#("error", json.string("Service unavailable"))])
      |> response.json(503)

    db.DecodeError(message: m) ->
      json.object([#("error", json.string(m))])
      |> response.json(500)
  }
}
