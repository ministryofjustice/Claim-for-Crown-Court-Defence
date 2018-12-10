class SelectOptionSection < SitePrism::Section
end

class LgfsInterimFeeSection < SitePrism::Section
  include SelectHelper

  sections :fee_type_select_options, SelectOptionSection, 'select#claim_interim_fee_attributes_fee_type_id option', visible: false
  element :select_container, 'select#claim_interim_fee_attributes_fee_type_id', visible: false

  # common interim fee fields
  element :ppe_total, '.fee-quantity'
  element :amount, ".fee-amount"

  # interim effective PCMH fee fields
  section :effective_pcmh_date, CommonDateSection, '.js-interim-effectivePcmh .gov_uk_date'

  # interim trial start fee fields
  element :estimated_trial_length, 'input#claim_estimated_trial_length'
  section :first_day_of_trial, CommonDateSection, '.js-interim-trialDates .gov_uk_date'

  # interim retrial start fee fields
  element :retrial_estimated_length, 'input#claim_retrial_estimated_length'
  section :retrial_started_at, CommonDateSection, '.js-interim-retrialDates .gov_uk_date'

  # interim retrial (new solicitor) fee fields
  section :legal_aid_transfer_date, CommonDateSection, '.js-interim-legalAidTransfer .gov_uk_date:nth-of-type(1)'
  section :trial_concluded_at, CommonDateSection, '.js-interim-legalAidTransfer .gov_uk_date:nth-of-type(2)'

  # interim warrant fee fields
  section :warrant_issued_date, CommonDateSection, ".warrant-fee-issued-date-group .gov_uk_date"
  section :warrant_executed_date, CommonDateSection, ".warrant-fee-executed-date-group .gov_uk_date"

  def select_fee_type(name)
    select name, from: select_container[:id], autocomplete: false
  end

  def fee_type_select_names
    fee_type_select_options.map(&:text)
  end
end
