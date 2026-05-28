import app/app.{type App}

import compiled/loom/custom
import glimr/http/context.{type Context}
import glimr/http/response.{type Response}
import glimr/session

/// @get "/custom"
pub fn show(ctx: Context(App)) -> Response {
  session.put(ctx.session, "message", "This is a custom template!")

  custom.render(ctx) |> response.string_tree(200)
}
