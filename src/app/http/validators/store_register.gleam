import app/app.{type App}
import glimr/forms/validator.{type FormData, type Rule}
import glimr/http/context.{type Context}
import glimr/http/response.{type Response}
import glimr/response/redirect

pub type Data {
  Data(email: String, password: String, first_name: String, last_name: String)
}

fn rules(_ctx: Context(App)) -> List(Rule(Context(App))) {
  [
    validator.for("email", [
      validator.Required,
      validator.Email,
      validator.MaxLength(255),
    ]),
    validator.for("password", [
      validator.Required,
      validator.MinLength(8),
      validator.Confirmed("password_confirmation"),
    ]),
    validator.for("first_name", [
      validator.Required,
      validator.MinLength(1),
    ]),
    validator.for("last_name", [
      validator.Required,
      validator.MinLength(1),
    ]),
  ]
}

fn data(data: FormData) -> Data {
  Data(
    email: data.get("email"),
    password: data.get("password"),
    first_name: data.get("first_name"),
    last_name: data.get("last_name"),
  )
}

pub fn validate(ctx: Context(App), next: fn(Data) -> Response) {
  use validated <- validator.run(ctx, rules, data, redirect.back(ctx))

  next(validated)
}
