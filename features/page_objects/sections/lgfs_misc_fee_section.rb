class RadioSection < SitePrism::Section
  element :label, 'label'

  def click
    label.click
  end
end

class FeeTypeSection < SitePrism::Section
  sections :radios, RadioSection, '.multiple-choice'

  def radio_labels
    radios.map { |radio| radio.label.text }
  end

  def choose(label)
    radios.find { |radio| radio.label.text.match?(label) }.click
  end
end

class LgfsMiscFeeSection < SitePrism::Section
  section :fee_type, FeeTypeSection, '.fee-type'
  element :amount, 'input.total'

  def populated?
    amount.value.size > 0
  end
end
