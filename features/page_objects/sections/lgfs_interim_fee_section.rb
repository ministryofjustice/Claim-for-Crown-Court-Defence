class SelectOptionSection < SitePrism::Section
end

class LGFSInterimFeeSection < SitePrism::Section
  include SelectHelper

  sections :fee_type_select_options, SelectOptionSection, 'select#claim-interim-fee-attributes-fee-type-id-field option', visible: false
  element :select_container, '.fee-type select', visible: false

  # common interim fee fields
  element :ppe_total, '.fee-quantity'
  element :amount, ".fee-amount"

  # interim effective PCMH fee fields
  section :effective_pcmh_date, GOVUKDateSection, '#effective-pcmh-date'

  # interim trial start fee fields
  element :estimated_trial_length, '#estimated_trial_length input'
  section :first_day_of_trial, GOVUKDateSection, '#first_day_of_trial'

  # interim retrial start fee fields
  element :retrial_estimated_length, '#retrial_estimated_length input'
  section :retrial_started_at, GOVUKDateSection, '#retrial_started_at'

  # interim retrial (new solicitor) fee fields
  section :legal_aid_transfer_date, GOVUKDateSection, '#legal_aid_transfer_date'
  section :trial_concluded_at, GOVUKDateSection, '#trial_concluded_at'

  # interim warrant fee fields
  section :warrant_issued_date, GOVUKDateSection, ".warrant-fee-issued-date-group"
  section :warrant_executed_date, GOVUKDateSection, ".warrant-fee-executed-date-group"

  def select_fee_type(name)
    select name, from: select_container[:id], autocomplete: false
  end

  def fee_type_select_names
    fee_type_select_options.map(&:text)
  end
end
