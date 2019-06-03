require_relative 'sections/checkbox_fee_section'

class ProviderPage < BasePage
  set_url "/provider_management/providers/new"

  element :name, "input.name"

  sections :radios, RadioSection, '.multiple-choice'

  sections :checklist, '.multiple-choice' do
    element :label, 'label'
    element :checkbox, 'input[type="checkbox"]', visible: false
  end

  element :save_details, "input.button"

  def choose(label)
    radios.find { |radio| radio.label.text.match?(label) }.click
  end

  def checklist_item_for(label)
    checklist.find do |item|
      item.label.text.match?(Regexp.new(Regexp.escape(label), true))
    end
  end

  def check(label)
    page.check checklist_item_for(label).checkbox['id'], visible: false
  end

  def uncheck(label)
    page.uncheck checklist_item_for(label).checkbox['id'], visible: false
  end
end
