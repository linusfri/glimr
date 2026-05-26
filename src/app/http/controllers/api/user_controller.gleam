//// Welcome (API) Controller
////
//// This is an example API controller returning JSON. Routes are defined 
//// via annotation comments above handlers and compiled to pattern-match 
//// routers in /compiled/routes/. The default "api" route group 
//// (/api prefix) compiles to an api.gleam file.
////
//// https://github.com/glimr-org/glimr?tab=readme-ov-file#defining-routes
//// https://github.com/glimr-org/glimr?tab=readme-ov-file#route-groups
//// https://github.com/glimr-org/glimr?tab=readme-ov-file#controllers
//// https://github.com/gleam-lang/json
////

import app/app
import app/http/validators/user_store
import app/lib/error
import database/main/models/user/gen/user
import gleam/json
import gleam/result
import glimr/http/context
import glimr/http/response.{type Response}

/// @get "/api/user"
///
pub fn show() -> Response {
  json.string("Probably a user") |> response.json(200)
}

/// @post "/api/user"
///
pub fn store(ctx: context.Context(app.App)) -> Response {
  use data <- user_store.validate(ctx)

  let user_data = {
    use result <- result.try(user.create(
      ctx.app.db,
      data.first_name,
      data.last_name,
      "0700",
      data.email,
    ))

    Ok(result)
  }

  case user_data {
    Ok(user) -> user |> user.encoder() |> response.json(201)
    Error(db_error) -> {
      error.db_error_to_response(db_error)
    }
  }
}
