import app/app.{type App}
import app/repositories/form_config.{
  type NewFormConfig, NewFixed, NewFormConfigGrouped, NewFormConfigPriced,
  NewFormPrice, NewGroup, NewGroupFixed, NewGroupMix, NewGroupPrice, NewMix,
  NewScalarRate, NewSplitRate, NewSpot, NewVariable, NewWinterSecurity,
}
import gleam/dynamic/decode
import gleam/json
import gleam/option
import glimr/http/context.{type Context}
import glimr/http/response.{type Response}
import wisp

// ---------------------------------------------------------------------------
// Decoders
// ---------------------------------------------------------------------------

fn rate_decoder() -> decode.Decoder(form_config.NewPriceRateDetail) {
  use type_str <- decode.field("type", decode.string)
  case type_str {
    "split" -> {
      use fixed_rate <- decode.field("fixed_rate", decode.float)
      use variable_rate <- decode.field("variable_rate", decode.float)
      use valid_month <- decode.field("valid_month", decode.string)
      decode.success(NewSplitRate(fixed_rate:, variable_rate:, valid_month:))
    }
    _ -> {
      use rate <- decode.field("rate", decode.float)
      use valid_month <- decode.field("valid_month", decode.string)
      decode.success(NewScalarRate(rate:, valid_month:))
    }
  }
}

fn group_price_decoder() -> decode.Decoder(form_config.NewGroupPrice) {
  use signable_from <- decode.field("signable_from", decode.string)
  use signable_until <- decode.field("signable_until", decode.string)
  use is_best_value <- decode.field("is_best_value", decode.bool)
  use rate <- decode.field("rate", rate_decoder())
  decode.success(NewGroupPrice(
    signable_from:,
    signable_until:,
    is_best_value:,
    rate:,
  ))
}

fn group_decoder() -> decode.Decoder(form_config.NewGroup) {
  use title <- decode.field("title", decode.string)
  use contract_period_months <- decode.field(
    "contract_period_months",
    decode.int,
  )
  use yearly_fee <- decode.field("yearly_fee", decode.float)
  use visible_from <- decode.field("visible_from", decode.string)
  use visible_until <- decode.field("visible_until", decode.string)
  use fp <- decode.optional_field(
    "fixed_percent",
    option.None,
    decode.optional(decode.float),
  )
  use prices <- decode.field("prices", decode.list(group_price_decoder()))
  let detail = case fp {
    option.Some(fixed_percent) -> NewGroupMix(fixed_percent:)
    option.None -> NewGroupFixed
  }
  decode.success(NewGroup(
    title:,
    contract_period_months:,
    yearly_fee:,
    visible_from:,
    visible_until:,
    detail:,
    prices:,
  ))
}

fn form_price_decoder() -> decode.Decoder(form_config.NewFormPrice) {
  use signable_from <- decode.field("signable_from", decode.string)
  use signable_until <- decode.field("signable_until", decode.string)
  use is_best_value <- decode.field("is_best_value", decode.bool)
  use rate <- decode.field("rate", rate_decoder())
  decode.success(NewFormPrice(
    signable_from:,
    signable_until:,
    is_best_value:,
    rate:,
  ))
}

fn decoder() -> decode.Decoder(NewFormConfig) {
  use form_type <- decode.field("form_type", decode.string)
  case form_type {
    "variable" -> {
      use yearly_fee <- decode.field("yearly_fee", decode.float)
      use variable_costs <- decode.field("variable_costs", decode.float)
      use prices <- decode.field("prices", decode.list(form_price_decoder()))
      decode.success(NewFormConfigPriced(
        detail: NewVariable(yearly_fee:, variable_costs:),
        prices:,
      ))
    }
    "spot" -> {
      use yearly_fee <- decode.field("yearly_fee", decode.float)
      use variable_costs <- decode.field("variable_costs", decode.float)
      use surcharge <- decode.field("surcharge", decode.float)
      use prices <- decode.field("prices", decode.list(form_price_decoder()))
      decode.success(NewFormConfigPriced(
        detail: NewSpot(yearly_fee:, variable_costs:, surcharge:),
        prices:,
      ))
    }
    "mix" -> {
      use variable_costs <- decode.field("variable_costs", decode.float)
      use groups <- decode.field("groups", decode.list(group_decoder()))
      decode.success(NewFormConfigGrouped(
        detail: NewMix(variable_costs:),
        groups:,
      ))
    }
    "winter_security" -> {
      use groups <- decode.field("groups", decode.list(group_decoder()))
      decode.success(NewFormConfigGrouped(detail: NewWinterSecurity, groups:))
    }
    _ -> {
      use groups <- decode.field("groups", decode.list(group_decoder()))
      decode.success(NewFormConfigGrouped(detail: NewFixed, groups:))
    }
  }
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

pub fn validate(ctx: Context(App), next: fn(NewFormConfig) -> Response) {
  use body <- wisp.require_json(ctx.req)
  case decode.run(body, decoder()) {
    Ok(form) -> next(form)
    Error(_) ->
      json.object([#("error", json.string("Invalid request body"))])
      |> response.json(422)
  }
}
