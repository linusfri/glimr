import gleam/list
import gleam/time/calendar.{type Date, type Month}
import gleam/time/timestamp.{type Timestamp}

type Agreement {
  Agreement(
    fields: String,
    form: Form,
    start: SigningAction,
    vat: VatRate,
    energy_sources: List(EnergySource),
    attachments: List(Attachment),
  )
}

type Form {
  Form(title: String, description: String, pricing: PriceDetails)
}

// Fixed and WinterSecurity share this — price is a single kwh rate, no surcharge
type FixedGroup {
  FixedGroup(
    title: String,
    identifier: String,
    contract_period: Int,
    yearly_fee: Float,
    visible_from: Timestamp,
    visible_until: Timestamp,
    prices: List(Price),
  )
}

// Mix groups carry the fixed/variable split ratio
type MixGroup {
  MixGroup(
    title: String,
    identifier: String,
    contract_period: Int,
    yearly_fee: Float,
    fixed_percent: Float,
    visible_from: Timestamp,
    visible_until: Timestamp,
    prices: List(Price),
  )
}

type Price {
  Price(
    signable_from: Date,
    signable_until: Date,
    is_best_value: Bool,
    rate: PriceRate,
  )
}

type PriceRate {
  SingleRate(rate: Float)
  MonthlyRate(rate: Float, valid_month: Month)
  SplitRate(fixed_rate: Float, variable_rate: Float)
}

type PriceDetails {
  Fixed(groups: List(FixedGroup))
  Variable(yearly_fee: Float, variable_costs: Float, prices: List(Price))
  Mix(variable_costs: Float, groups: List(MixGroup))
  Spot(
    yearly_fee: Float,
    variable_costs: Float,
    surcharge: Float,
    prices: List(Price),
  )
  WinterSecurity(groups: List(FixedGroup))
}

type SigningAction {
  NewAgreement
  Resign
  Move
  AssignedPrice
  Company
}

type EnergySource {
  EnergySource(label: String, value: String, price: Float)
}

type Attachment {
  Attachment(file_id: String)
}

type VatRate {
  VatRate(percent: Float)
}
