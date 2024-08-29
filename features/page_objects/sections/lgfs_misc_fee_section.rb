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
  element :quantity, "input.quantity"
  section :fee_type, FeeTypeSection, '.fee-type'
  element :amount, 'input.total'

  def populated?
    amount.value.size > 0
  end
end
