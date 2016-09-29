class InterimFeeSection < SitePrism::Section
  include SelectHelper

  element :select_container, 'select#claim_interim_fee_attributes_fee_type_id', visible: false

  element :total, '#claim_interim_fee_attributes_amount'
  element :ppe_total, '#claim_interim_fee_attributes_quantity'
  section :effective_pcmh_date, CommonDateSection, '.js-interim-effectivePcmh'

  def select_fee_type(name)
    id = select_container[:id]
    select name, from: id, autocomplete: false
  end
end
