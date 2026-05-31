import app/app.{type App}
import app/http/validators/store_electricity_form
import app/lib/error
import app/repositories/form_config
import gleam/json
import glimr/http/context.{type Context}
import glimr/http/response.{type Response}

/// @post "/api/forms"
pub fn store(ctx: Context(App)) -> Response {
  use request_data <- store_electricity_form.validate(ctx)

  let result = form_config.create(ctx.app.db, request_data)

  case result {
    Ok(_) -> {
      json.string("Created") |> response.json(201)
    }
    Error(db_error) -> error.db_error_to_response(db_error)
  }
}
