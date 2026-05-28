import app/app.{type App}
import app/http/middleware/guest_user
import app/http/validators/store_register
import compiled/loom/auth/register
import database/main/models/user/gen/user
import glimr/http/context.{type Context}
import glimr/http/middleware.{type Middleware}
import glimr/http/response.{type Response}
import glimr/response/redirect
import glimr/session
import glimr/utils/unix_timestamp

/// Apply the guest middleware to the entire controller
pub fn middleware() -> List(Middleware(App)) {
  [guest_user.run]
}

/// @get "/register"
pub fn show(ctx: Context(App)) -> Response {
  register.render(ctx: ctx) |> response.string_tree(200)
}

/// @post "/register"
pub fn store(ctx: Context(App)) -> Response {
  use validated <- store_register.validate(ctx)

  let registered = {
    use pool, hashed_password <- user.register(
      session: ctx.session,
      pool: ctx.app.db,
      password: validated.password,
    )

    user.create(
      pool: pool,
      email: validated.email,
      password: hashed_password,
      first_name: validated.first_name,
      last_name: validated.last_name,
    )
  }

  case registered {
    Ok(_) -> {
      let message = "Account created successfully"

      session.flash(ctx.session, "message", message)

      redirect.to(guest_user.auth_redirect)
    }
    Error(_) -> {
      let message = "Registration failed"

      session.flash(ctx.session, "error", message)

      redirect.back(ctx)
    }
  }
}
