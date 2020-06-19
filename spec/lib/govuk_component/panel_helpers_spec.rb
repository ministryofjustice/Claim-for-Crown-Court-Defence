# frozen_string_literal: true

RSpec.describe GovukComponent::PanelHelpers, type: :helper do
  describe '#govuk_panel' do
    it 'renders govuk-panel component' do
      rendered = helper.govuk_panel('Application complete', 'Your reference number<br><strong>HDJ2123F</strong>')
      expected_markup = '<div class="govuk-panel govuk-panel--confirmation">'\
                        '<h1 class="govuk-panel__title">Application complete</h1>'\
                        '<div class="govuk-panel__body">Your reference number<br><strong>HDJ2123F</strong></div>'\
                        '</div>'

      expect(rendered).to eql expected_markup
    end
  end
end
