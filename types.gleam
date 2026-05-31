import gleam/dict.{type Dict}
import gleam/list.{type List}
import gleam/option.{type Option}
import gleam/time/calendar.{type Date, type Month}
import gleam/time/timestamp.{type Timestamp}

type Agreement {
  Agreement(
    form: Form,
    sign_type: SignType,
    vat: VatRate,
    energy_sources: List(EnergySource),
  )
}

type Form {
  Form(title: String, description: String, pricing: PriceDetails)
}

type Group {
  Group(
    title: String,
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

// --- Calculated price output ---

// Most price fields carry both a current value (possibly discounted) and the original
type PriceValue {
  PriceValue(value: Float, valueInclVat: Float, original_value: Float)
}

type Comparison {
  Comparison(consumption: Float, price: Float)
}

// Common calculated fields shared by all form types
type CalculatedPrice {
  CalculatedPrice(
    energy_source: PriceValue,
    yearly_fee: Float,
    yearly_kwh_fee: PriceValue,
    vat: PriceValue,
    kwh_total: PriceValue,
    variable_costs: PriceValue,
    surcharge: PriceValue,
    spot_price: PriceValue,
    total: PriceValue,
    comparisons: List(Comparison),
    breakdown: CalculatedBreakdown,
  )
}

// Mix has a different kwh_price shape and different fee/lime fields
type CalculatedBreakdown {
  StandardBreakdown(
    kwh_price: Float,
    kwh_price_incl_vat: Float,
    kwh_price_incl_fees: PriceValue,
    kwh_price_incl_fees_incl_vat: PriceValue,
    lime_price: LimePrice,
  )
  MixBreakdown(
    kwh_price: Float,
    kwh_price_incl_vat: Float,
    fixed_kwh_price: SplitKwhPrice,
    variable_kwh_price: SplitKwhPrice,
    variable_kwh_price_incl_fees: PriceValue,
    variable_kwh_price_incl_fees_incl_vat: PriceValue,
    lime_price: LimePrice,
  )
}

type SplitKwhPrice {
  SplitKwhPrice(
    value: Float,
    original_value: Float,
    value_incl_vat: Float,
    percent: Float,
  )
}

type LimePrice {
  StandardLimePrice(rate: Float)
  MixLimePrice(fixed: Float, variable: Float, fixed_percent: Float)
}

type SignType {
  NewAgreement
  Resign
  Move
  AssignedPrice
  Company
}

type EnergySource {
  EnergySource(label: String, value: String, price: Float)
}

type VatRate {
  VatRate(percent: Float)
}

// --- Agreement submission ---

type AgreementSubmission {
  AgreementSubmission(
    sign_type: SignType,
    start_date: Date,
    end_date: Date,
    branch: Option(String),
    energy_source: String,
    exchange_right: Bool,
    other_supplier: Bool,
    yearly_fee: Float,
    notes: Option(String),
    facility: SubmissionFacility,
    campaign: Option(SubmissionCampaign),
    price: SubmissionPrice,
  )
}

type SubmissionFacility {
  SubmissionFacility(
    facility_id: Option(String),
    yearly_consumption: Int,
    portfolio: Option(String),
  )
}

type SubmissionCampaign {
  SubmissionCampaign(campaign_id: String, offer_type: Option(String))
}

type SubmissionPrice {
  FixedSubmission(price: Float, price_addition: Float)
  VariableSubmission(price_variable: Float, price_addition: Float)
  MixSubmission(
    price: Float,
    price_variable: Float,
    fixed_percent: Float,
    price_addition: Float,
  )
  SpotSubmission(
    hourly_price: Float,
    price_variable: Float,
    price_addition: Float,
  )
}
