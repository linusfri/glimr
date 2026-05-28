import gleam/dict.{type Dict}
import gleam/list.{type List}
import gleam/time/calendar.{type Date, type Month}
import gleam/time/timestamp.{type Timestamp}

type Agreement {
  Agreement(
    fields: List(Dict(String, String)),
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

type Group {
  Group(
    title: String,
    identifier: String,
    contract_period: Int,
    yearly_fee: Float,
    visible_from: Timestamp,
    visible_until: Timestamp,
    prices: List(Price),
    details: GroupDetails,
  )
}

type GroupDetails {
  FixedGroup
  MixGroup(fixed_percent: Float)
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
  Fixed(groups: List(Group))
  Variable(yearly_fee: Float, variable_costs: Float, prices: List(Price))
  Mix(variable_costs: Float, groups: List(Group))
  Spot(
    yearly_fee: Float,
    variable_costs: Float,
    surcharge: Float,
    prices: List(Price),
  )
  WinterSecurity(groups: List(Group))
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
