# frozen_string_literal: true

RSpec.describe GovukComponent::PanelHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_panel' do
    subject(:markup) { helper.govuk_panel('My panel heading', 'My content') }

    it 'adds panel with govuk class' do
      is_expected.to have_tag(:div, with: { class: 'govuk-panel govuk-panel--confirmation' })
    end

    it 'adds nested h1 tag with govuk class' do
      is_expected.to have_tag(:div) do
        with_tag(:h1, with: { class: 'govuk-panel__title' }, text: 'My panel heading')
      end
    end

    it 'adds nested div tag with govuk class' do
      is_expected.to have_tag(:div) do
        with_tag(:div, with: { class: 'govuk-panel__body' }, text: 'My content')
      end
    end

    context 'with custom classes' do
      subject(:markup) do
        helper.govuk_panel('My panel heading', 'My content', class: 'my-custom-class1 my-custom-class2')
      end

      it 'adds panel with custom classes, prepended by govuk class' do
        is_expected.to have_tag(:div, with: { class: 'govuk-panel govuk-panel--confirmation my-custom-class1 my-custom-class2' })
      end
    end
  end
end
