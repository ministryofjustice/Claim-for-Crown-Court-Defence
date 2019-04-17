require_relative 'radio_section'

class YesNoSection < SitePrism::Section
  sections :radios, RadioSection, '.multiple-choice'

  def radio_labels
    radios.map { |radio| radio.label.text }
  end

  def choose(label)
    radios.find { |radio| radio.label.text.match?(label) }.click
  end
end