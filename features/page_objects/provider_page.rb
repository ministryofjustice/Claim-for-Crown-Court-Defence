require_relative 'sections/checklist_section'

class ProviderPage < BasePage
  set_url '/provider_management/providers/new'

  element :name, 'input#provider-name-field'

  sections :radios, RadioSection, '.multiple-choice'

  section :fee_schemes, ChecklistSection, 'div#js-fee-schemes'

  element :save_details, 'button.govuk-button', text: 'Save details'

  def choose(label)
    radios.find { |radio| radio.label.text.match?(label) }.click
  end
end
