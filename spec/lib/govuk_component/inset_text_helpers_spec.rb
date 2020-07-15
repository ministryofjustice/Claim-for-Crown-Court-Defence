# frozen_string_literal: true

RSpec.describe GovukComponent::InsetTextHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_inset_text' do
    subject(:markup) { helper.govuk_inset_text { 'My content' } }

    it 'adds inset text with govuk class' do
      is_expected.to have_tag(:div, with: { class: 'govuk-inset-text' })
    end

    it 'yields content to div tag' do
      is_expected.to have_tag(:div, with: { class: 'govuk-inset-text' }, text: 'My content')
    end

    context 'with custom classes' do
      subject(:markup) do
        helper.govuk_inset_text(class: 'my-custom-class1 my-custom-class2') { 'My content' }
      end

      it 'adds inset text with custom classes, prepended by govuk class' do
        is_expected.to have_tag(:div, with: { class: 'govuk-inset-text my-custom-class1 my-custom-class2' })
      end
    end
  end
end
