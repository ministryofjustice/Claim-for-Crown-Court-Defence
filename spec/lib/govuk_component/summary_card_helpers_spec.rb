# frozen_string_literal: true

RSpec.describe GovukComponent::SummaryCardHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_summary_card' do
    subject(:markup) { helper.govuk_summary_card(title, content) }

    let(:title) { 'Additional information' }
    let(:content) { 'Lorem ipsum dolor sit amet' }

    it 'adds div tags with govuk class abd displays a title and content' do
      is_expected.to have_tag(:div, with: { class: 'govuk-summary-card' }) do
        check_title
        check_content
      end
    end

    def check_title
      with_tag(:div, with: { class: 'govuk-summary-card__title-wrapper' }) do
        with_tag(:h2, with: { class: 'govuk-summary-card__title' }, text: title)
      end
    end

    def check_content
      with_tag(:div, with: { class: 'govuk-summary-card__content' }, text: content)
    end
  end
end
