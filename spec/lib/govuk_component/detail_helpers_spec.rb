# frozen_string_literal: true

RSpec.describe GovukComponent::DetailHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_detail' do
    subject(:markup) { helper.govuk_detail('My detail summary text') { 'My content' } }

    it 'adds detail with govuk class' do
      is_expected.to have_tag(:details, with: { class: 'govuk-details' })
    end

    it 'adds detail without open attribute' do
      is_expected.to have_tag(:details, without: { open: 'open' })
    end

    it 'adds detail govuk data-module' do
      is_expected.to have_tag(:details, with: { 'data-module': 'govuk-details' })
    end

    it 'adds nested summary tag with govuk class' do
      is_expected.to have_tag(:details) do
        with_tag(:summary, with: { class: 'govuk-details__summary' })
      end
    end

    it 'adds nested span in summary tag with govuk class' do
      is_expected.to have_tag(:details) do
        with_tag(:summary) do
          with_tag(:span, with: { class: 'govuk-details__summary-text' })
        end
      end
    end

    it 'adds summary_text to nested span' do
      is_expected.to have_tag(:details) do
        with_tag(:summary) do
          with_tag(:span, text: 'My detail summary text')
        end
      end
    end

    it 'adds nested div tag with govuk class' do
      is_expected.to have_tag(:details) do
        with_tag(:div, with: { class: 'govuk-details__text' })
      end
    end

    it 'yields content to nested div tag' do
      is_expected.to have_tag(:details) do
        with_tag(:div, with: { class: 'govuk-details__text' }) do
          with_text 'My content'
        end
      end
    end

    context 'with open true' do
      subject(:markup) { helper.govuk_detail('My detail summary text', open: true) { 'my content' } }

      it 'adds detail with open attribute' do
        is_expected.to have_tag(:details, with: { open: 'open' })
      end
    end

    context 'with custom classes' do
      subject(:markup) do
        helper.govuk_detail('My detail summary text', class: 'my-custom-class1 my-custom-class2') do
          'my content'
        end
      end

      it 'adds detail with custom classes, prepended by govuk class' do
        is_expected.to have_tag(:details, with: { class: 'govuk-details my-custom-class1 my-custom-class2' })
      end
    end
  end
end
