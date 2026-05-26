import app/app.{type App}
import glimr/forms/validator.{type FormData, type Rule}
import glimr/http/context.{type Context}
import glimr/http/response.{type Response}

// docs: https://github.com/glimr-org/glimr?tab=readme-ov-file#form-validation

/// Define the shape of the data returned after validation
///
pub type Data {
  // Data(name: String)
  Data(first_name: String, last_name: String, email: String)
}

/// Define your form's validation rules
///
fn rules(_ctx: Context(App)) -> List(Rule(Context(App))) {
  [
    validator.for("first_name", [validator.Required, validator.MinLength(2)]),
    validator.for("last_name", [
      validator.Required,
      validator.MinLength(2),
    ]),
    validator.for("email", [validator.Required]),
  ]
}

/// Set the form data returned after validation. This is also
/// where you can transform validated input data before it
/// reaches your controller.
///
fn data(data: FormData) -> Data {
  Data(
    first_name: data.get("first_name"),
    last_name: data.get("last_name"),
    email: data.get("email"),
  )
}

/// Run your validation rules. This is your entry point, you
/// dont't usually have to adjust anything in this function, but
/// you can if you want to add any custom logic before/after
/// validation.
///
pub fn validate(ctx: Context(App), next: fn(Data) -> Response) {
  use validated <- validator.run(ctx, rules, data, response.redirect("/"))

  next(validated)
}
