class SelectOptionSection < SitePrism::Section
end

class InterimFeeSection < SitePrism::Section
  include SelectHelper

  sections :fee_type_select_options, SelectOptionSection, 'select#claim_interim_fee_attributes_fee_type_id option', visible: false
  element :select_container, 'select#claim_interim_fee_attributes_fee_type_id', visible: false

  element :total, '#claim_interim_fee_attributes_amount'
  element :ppe_total, '#claim_interim_fee_attributes_quantity'
  section :effective_pcmh_date, CommonDateSection, '.js-interim-effectivePcmh'

  def select_fee_type(name)
    select name, from: select_container[:id], autocomplete: false
  end

  def fee_type_select_names
    fee_type_select_options.map(&:text)
  end
end
