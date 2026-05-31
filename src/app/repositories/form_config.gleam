import database/main/models/form_config/gen/form_config.{type FormConfig}
import database/main/models/form_config_mix/gen/form_config_mix
import database/main/models/form_config_spot/gen/form_config_spot
import database/main/models/form_config_variable/gen/form_config_variable
import database/main/models/form_price/gen/form_price
import database/main/models/form_price_rate/gen/form_price_rate
import database/main/models/form_price_rate_scalar/gen/form_price_rate_scalar
import database/main/models/form_price_rate_split/gen/form_price_rate_split
import database/main/models/group/gen/group as group_model
import database/main/models/group_mix/gen/group_mix
import database/main/models/group_price/gen/group_price
import database/main/models/group_price_rate/gen/group_price_rate
import database/main/models/group_price_rate_scalar/gen/group_price_rate_scalar
import database/main/models/group_price_rate_split/gen/group_price_rate_split
import gleam/list
import gleam/result
import glimr/db/db

// ---------------------------------------------------------------------------
// Input types
// ---------------------------------------------------------------------------

// Shared rate detail — used by both form prices and group prices
pub type NewPriceRateDetail {
  NewScalarRate(rate: Float, valid_month: Int)
  NewSplitRate(fixed_rate: Float, variable_rate: Float, valid_month: Int)
}

// Form prices (variable / spot only)
pub type NewFormPrice {
  NewFormPrice(
    signable_from: Int,
    signable_until: Int,
    is_best_value: Bool,
    rate: NewPriceRateDetail,
  )
}

// Group detail — fixed_percent only relevant for mix
pub type NewGroupDetail {
  NewGroupFixed
  NewGroupMix(fixed_percent: Float)
}

// Group price
pub type NewGroupPrice {
  NewGroupPrice(
    signable_from: Int,
    signable_until: Int,
    is_best_value: Bool,
    rate: NewPriceRateDetail,
  )
}

pub type NewGroup {
  NewGroup(
    title: String,
    contract_period_months: Int,
    yearly_fee: Float,
    visible_from: Int,
    visible_until: Int,
    detail: NewGroupDetail,
    prices: List(NewGroupPrice),
  )
}

// The two constructors enforce the constraint at the type level:
//   - Grouped (fixed / mix / winter_security) carries groups, never prices
//   - Priced  (variable / spot)               carries prices, never groups
pub type NewFormConfigGroupedDetail {
  NewFixed
  NewWinterSecurity
  NewMix(variable_costs: Float)
}

pub type NewFormConfigPricedDetail {
  NewVariable(yearly_fee: Float, variable_costs: Float)
  NewSpot(yearly_fee: Float, variable_costs: Float, surcharge: Float)
}

pub type NewFormConfig {
  NewFormConfigGrouped(
    detail: NewFormConfigGroupedDetail,
    groups: List(NewGroup),
  )
  NewFormConfigPriced(
    detail: NewFormConfigPricedDetail,
    prices: List(NewFormPrice),
  )
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Creates a form_config and all downstream records in a single transaction.
/// The constructor used determines which path is taken:
///   NewFormConfigGrouped → fixed/mix/winter_security, inserts groups + group_prices
///   NewFormConfigPriced  → variable/spot, inserts form_prices
pub fn create(
  pool pool: db.DbPool,
  form_data form_data: NewFormConfig,
) -> Result(FormConfig, db.DbError) {
  use conn <- db.transaction(pool, 3)

  case form_data {
    NewFormConfigPriced(detail:, prices:) -> {
      let form_type = case detail {
        NewVariable(..) -> form_config.Variable
        NewSpot(..) -> form_config.Spot
      }
      use form_config <- result.try(form_config.create_wc(
        connection: conn,
        form_type:,
      ))
      use _ <- result.try(create_priced_detail(conn, form_config.id, detail))
      use _ <- result.try(
        list.try_map(prices, fn(price) {
          create_form_price(conn, form_config.id, price)
        }),
      )
      Ok(form_config)
    }

    NewFormConfigGrouped(detail:, groups:) -> {
      let form_type = case detail {
        NewFixed -> form_config.Fixed
        NewWinterSecurity -> form_config.WinterSecurity
        NewMix(..) -> form_config.Mix
      }
      use config <- result.try(form_config.create_wc(
        connection: conn,
        form_type:,
      ))
      use _ <- result.try(create_grouped_detail(conn, config.id, detail))
      use _ <- result.try(
        list.try_map(groups, fn(group) { create_group(conn, config.id, group) }),
      )
      Ok(config)
    }
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

fn create_priced_detail(
  conn: db.Connection,
  form_config_id: Int,
  detail: NewFormConfigPricedDetail,
) -> Result(Int, db.DbError) {
  case detail {
    NewVariable(yearly_fee:, variable_costs:) -> {
      form_config_variable.create_wc(
        connection: conn,
        form_config_id:,
        yearly_fee:,
        variable_costs:,
      )
    }
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

fn create_grouped_detail(
  conn: db.Connection,
  form_config_id: Int,
  detail: NewFormConfigGroupedDetail,
) -> Result(Int, db.DbError) {
  case detail {
    NewFixed | NewWinterSecurity -> Ok(0)

    NewMix(variable_costs:) ->
      form_config_mix.create_wc(
        connection: conn,
        form_config_id:,
        variable_costs:,
      )
  }
}

fn create_form_price(
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
    NewScalarRate(..) -> form_price_rate.Scalar
    NewSplitRate(..) -> form_price_rate.Split
  }

  use rate_row <- result.try(form_price_rate.create_wc(
    connection: conn,
    form_price_id: price_row.id,
    rate_type:,
  ))

  create_form_rate_detail(conn, rate_row.id, price.rate)
}

fn create_form_rate_detail(
  conn: db.Connection,
  form_price_rate_id: Int,
  detail: NewPriceRateDetail,
) -> Result(Int, db.DbError) {
  case detail {
    NewScalarRate(rate:, valid_month:) ->
      form_price_rate_scalar.create_wc(
        connection: conn,
        form_price_rate_id:,
        rate:,
        valid_month:,
      )

    NewSplitRate(fixed_rate:, variable_rate:, valid_month:) ->
      form_price_rate_split.create_wc(
        connection: conn,
        form_price_rate_id:,
        fixed_rate:,
        variable_rate:,
        valid_month:,
      )
  }
}

fn create_group(
  conn: db.Connection,
  form_config_id: Int,
  group_input: NewGroup,
) -> Result(Nil, db.DbError) {
  let group_type = case group_input.detail {
    NewGroupFixed -> group_model.Fixed
    NewGroupMix(..) -> group_model.Mix
  }

  use group_row <- result.try(group_model.create_wc(
    connection: conn,
    form_config_id:,
    group_type:,
    title: group_input.title,
    contract_period_months: group_input.contract_period_months,
    yearly_fee: group_input.yearly_fee,
    visible_from: group_input.visible_from,
    visible_until: group_input.visible_until,
  ))

  use _ <- result.try(create_group_detail(
    conn,
    group_row.id,
    group_input.detail,
  ))

  list.try_map(group_input.prices, fn(price) {
    create_group_price(conn, group_row.id, price)
  })
  |> result.map(fn(_) { Nil })
}

fn create_group_detail(
  conn: db.Connection,
  group_id: Int,
  detail: NewGroupDetail,
) -> Result(Nil, db.DbError) {
  case detail {
    NewGroupFixed -> Ok(Nil)

    NewGroupMix(fixed_percent:) ->
      group_mix.create_wc(connection: conn, group_id:, fixed_percent:)
      |> result.map(fn(_) { Nil })
  }
}

fn create_group_price(
  conn: db.Connection,
  group_id: Int,
  price: NewGroupPrice,
) -> Result(Nil, db.DbError) {
  use price_row <- result.try(group_price.create_wc(
    connection: conn,
    group_id:,
    signable_from: price.signable_from,
    signable_until: price.signable_until,
    is_best_value: price.is_best_value,
  ))

  let rate_type = case price.rate {
    NewScalarRate(..) -> group_price_rate.Scalar
    NewSplitRate(..) -> group_price_rate.Split
  }

  use rate_row <- result.try(group_price_rate.create_wc(
    connection: conn,
    group_price_id: price_row.id,
    rate_type:,
  ))

  create_group_rate_detail(conn, rate_row.id, price.rate)
}

fn create_group_rate_detail(
  conn: db.Connection,
  group_price_rate_id: Int,
  detail: NewPriceRateDetail,
) -> Result(Nil, db.DbError) {
  let result = case detail {
    NewScalarRate(rate:, valid_month:) ->
      group_price_rate_scalar.create_wc(
        connection: conn,
        group_price_rate_id:,
        rate:,
        valid_month:,
      )

    NewSplitRate(fixed_rate:, variable_rate:, valid_month:) ->
      group_price_rate_split.create_wc(
        connection: conn,
        group_price_rate_id:,
        fixed_rate:,
        variable_rate:,
        valid_month:,
      )
  }

  result |> result.map(fn(_) { Nil })
}
