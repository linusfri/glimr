import app/app.{type App}
import app/http/middleware/auth_user
import compiled/loom/dashboard
import gleam/option
import glimr/http/context.{type Context}
import glimr/http/middleware
import glimr/http/response.{type Response}

/// @get "/dashboard"
pub fn show(ctx: Context(App)) -> Response {
  use ctx <- middleware.apply([auth_user.run], ctx)

  let assert option.Some(user) = ctx.app.user

  dashboard.render(ctx: ctx, user: user)
  |> response.string_tree(200)
}
