require_relative 'radio_section'

class FeeTypeSection < SitePrism::Section
  sections :radios, RadioSection, '.govuk-radios__item'


  def radio_labels
    radios.map { |radio| radio.label.text.gsub(/\n(.*)/, '') }
  end

  def choose(label)
    radios.find { |radio| radio.label.text.match?(label) }.click
  end
end

class LGFSMiscFeeSection < SitePrism::Section
  section :govuk_fee_type_autocomplete, CommonAutocomplete, ".cc-fee-type"
  element :govuk_fee_type_autocomplete_input, ".cc-fee-type input", visible: true
  element :quantity, "input.quantity"
  element :rate, "input.rate"
  section :fee_type, FeeTypeSection, '.fee-type'
  element :net_amount, '.fee-net-amount'


  def populated?
    amount.value.size > 0
  end
end
