require_relative 'sections/checklist_section'

class ProviderPage < BasePage
  set_url "/provider_management/providers/new"

  element :name, "input.name"

  sections :radios, RadioSection, '.multiple-choice'

  section :fee_schemes, ChecklistSection, "div#js-fee-schemes"

  element :save_details, "input.button"

  def choose(label)
    radios.find { |radio| radio.label.text.match?(label) }.click
  end
end
