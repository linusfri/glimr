import app/app
import app/http/validators/user_store
import app/lib/error
import database/main/models/user/gen/user
import gleam/json
import gleam/option
import glimr/http/context
import glimr/http/response.{type Response}

/// @get "/api/users"
///
pub fn show(ctx: context.Context(app.App)) -> Response {
  let result = user.list(ctx.app.db)

  case result {
    Ok(users) -> json.array(users, user.encoder()) |> response.json(200)
    Error(db_error) -> error.db_error_to_response(db_error)
  }
}

/// @post "/api/users"
///
pub fn store(ctx: context.Context(app.App)) -> Response {
  use data <- user_store.validate(ctx)

  let result =
    user.create(
      ctx.app.db,
      data.first_name,
      data.last_name,
      option.unwrap(data.phone, ""),
      data.email,
    )

  case result {
    Ok(user) -> user |> user.encoder() |> response.json(201)
    Error(db_error) -> {
      error.db_error_to_response(db_error)
    }
  }
}
