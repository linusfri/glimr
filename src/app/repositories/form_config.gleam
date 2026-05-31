import database/main/models/form_config/gen/form_config.{
  type FormConfig, Fixed, Mix, Spot, Variable, WinterSecurity,
}
import database/main/models/form_config_mix/gen/form_config_mix
import database/main/models/form_config_spot/gen/form_config_spot
import database/main/models/form_config_variable/gen/form_config_variable
import database/main/models/form_price/gen/form_price
import database/main/models/form_price_rate/gen/form_price_rate.{
  Monthly, Single, Split,
}
import database/main/models/form_price_rate_monthly/gen/form_price_rate_monthly
import database/main/models/form_price_rate_scalar/gen/form_price_rate_scalar
import database/main/models/form_price_rate_split/gen/form_price_rate_split
import gleam/list
import gleam/result
import glimr/db/db

// ---------------------------------------------------------------------------
// Input types
// ---------------------------------------------------------------------------

pub type NewFormConfigDetail {
  NewFixed
  NewWinterSecurity
  NewVariable(yearly_fee: Float, variable_costs: Float)
  NewMix(variable_costs: Float)
  NewSpot(yearly_fee: Float, variable_costs: Float, surcharge: Float)
}

pub type NewMonthlyRate {
  NewMonthlyRate(valid_month: String, rate: Float)
}

pub type NewPriceRateDetail {
  NewScalarRate(rate: Float)
  NewMonthlyRates(months: List(NewMonthlyRate))
  NewSplitRate(fixed_rate: Float, variable_rate: Float)
}

pub type NewFormPrice {
  NewFormPrice(
    signable_from: String,
    signable_until: String,
    is_best_value: Bool,
    rate: NewPriceRateDetail,
  )
}

pub type NewFormConfig {
  NewFormConfig(
    agreement_id: Int,
    detail: NewFormConfigDetail,
    prices: List(NewFormPrice),
  )
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Creates a form_config and all downstream records in a single transaction.
/// Depending on `detail`, the matching type-specific config row is created
/// (form_configs_variable / _mix / _spot). Each price and its rate chain is
/// then created automatically.
pub fn create(
  pool pool: db.DbPool,
  form_data form_data: NewFormConfig,
) -> Result(FormConfig, db.DbError) {
  use conn <- db.transaction(pool, 3)

  let form_type = case form_data.detail {
    NewFixed -> Fixed
    NewVariable(..) -> Variable
    NewMix(..) -> Mix
    NewSpot(..) -> Spot
    NewWinterSecurity -> WinterSecurity
  }

  use config <- result.try(form_config.create_wc(
    connection: conn,
    agreement_id: form_data.agreement_id,
    form_type:,
  ))
  use _ <- result.try(create_detail(conn, config.id, form_data.detail))
  use _ <- result.try(
    list.try_map(form_data.prices, fn(price) {
      create_price(conn, config.id, price)
    }),
  )

  Ok(config)
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

fn create_detail(
  conn: db.Connection,
  form_config_id: Int,
  detail: NewFormConfigDetail,
) -> Result(Int, db.DbError) {
  case detail {
    NewFixed | NewWinterSecurity -> Ok(0)

    NewVariable(yearly_fee:, variable_costs:) ->
      form_config_variable.create_wc(
        connection: conn,
        form_config_id:,
        yearly_fee:,
        variable_costs:,
      )

    NewMix(variable_costs:) ->
      form_config_mix.create_wc(
        connection: conn,
        form_config_id:,
        variable_costs:,
      )

    NewSpot(yearly_fee:, variable_costs:, surcharge:) ->
      form_config_spot.create_wc(
        connection: conn,
        form_config_id:,
        yearly_fee:,
        variable_costs:,
        surcharge:,
      )
  }
}

fn create_price(
  conn: db.Connection,
  form_config_id: Int,
  price: NewFormPrice,
) -> Result(Int, db.DbError) {
  use price_row <- result.try(form_price.create_wc(
    connection: conn,
    form_config_id:,
    signable_from: price.signable_from,
    signable_until: price.signable_until,
    is_best_value: price.is_best_value,
  ))

  let rate_type = case price.rate {
    NewScalarRate(..) -> Single
    NewMonthlyRates(..) -> Monthly
    NewSplitRate(..) -> Split
  }

  use rate_row <- result.try(form_price_rate.create_wc(
    connection: conn,
    form_price_id: price_row.id,
    rate_type:,
  ))

  create_rate_detail(conn, rate_row.id, price.rate)
}

fn create_rate_detail(
  conn: db.Connection,
  form_price_rate_id: Int,
  detail: NewPriceRateDetail,
) -> Result(Int, db.DbError) {
  case detail {
    NewScalarRate(rate:) ->
      form_price_rate_scalar.create_wc(
        connection: conn,
        form_price_rate_id:,
        rate:,
      )

    NewMonthlyRates(months:) ->
      list.try_map(months, fn(month) {
        form_price_rate_monthly.create_wc(
          connection: conn,
          form_price_rate_id:,
          rate: month.rate,
          valid_month: month.valid_month,
        )
      })
      |> result.map(fn(_) { 0 })

    NewSplitRate(fixed_rate:, variable_rate:) ->
      form_price_rate_split.create_wc(
        connection: conn,
        form_price_rate_id:,
        fixed_rate:,
        variable_rate:,
      )
  }
}
