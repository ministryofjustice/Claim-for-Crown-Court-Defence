# frozen_string_literal: true

RSpec.describe GovukComponent::SummaryListHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_summary_list' do
    subject(:markup) do
      helper.govuk_summary_list do end
    end

    it 'adds tag with govuk class' do
      is_expected.to have_tag(:dl, with: { class: 'govuk-summary-list' })
    end

    context 'with custom classes' do
      subject(:markup) do
        helper.govuk_summary_list(class: 'my-custom-class1 my-custom-class2') do end
      end

      it 'adds tag with custom classes, prepended by govuk class' do
        is_expected.to have_tag(:dl, with: { class: 'govuk-summary-list my-custom-class1 my-custom-class2' })
      end
    end
  end

  describe '#govuk_summary_list_row' do
    subject(:markup) { helper.govuk_summary_list_row('Name', 'Edit') { 'John Doe' } }

    it 'adds tag with govuk class' do
      is_expected.to have_tag(:div, with: { class: 'govuk-summary-list__row' })
    end

    it 'adds nested dt tag with govuk class' do
      is_expected.to have_tag(:div) do
        with_tag(:dt, with: { class: 'govuk-summary-list__key' }, text: 'Name')
      end
    end

    it 'adds nested dd tag with govuk class' do
      is_expected.to have_tag(:div) do
        with_tag(:dd, with: { class: 'govuk-summary-list__value' }, text: 'John Doe')
      end
    end

    it 'adds nested dd tag with govuk class' do
      is_expected.to have_tag(:div) do
        with_tag(:dd, with: { class: 'govuk-summary-list__actions' }, text: 'Edit')
      end
    end
  end
end
