# frozen_string_literal: true

RSpec.describe GovukComponent::ButtonHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_button' do
    subject(:markup) { helper.govuk_button('Save and continue') }

    it 'adds a default govuk button' do
      is_expected.to have_tag(:button, with: { class: 'govuk-button', 'data-module': 'govuk-button' }, text: 'Save and continue')
    end

    context 'with custom classes' do
      subject(:markup) do
        helper.govuk_button('Save and continue', class: 'my-custom-class1 my-custom-class2')
      end

      it 'adds a default govuk button with custom classes' do
        is_expected.to have_tag(:button, with: { class: 'govuk-button my-custom-class1 my-custom-class2', 'data-module': 'govuk-button' }, text: 'Save and continue')
      end
    end

    context 'when disabled' do
      subject(:markup) do
        helper.govuk_button('Save and continue', disabled: true)
      end

      it 'adds a default disabled govuk button' do
        is_expected.to have_tag(:button, with: { class: 'govuk-button', 'data-module': 'govuk-button', disabled: 'disabled', 'aria-disabled': 'true' }, text: 'Save and continue')
      end
    end
  end

  describe '#govuk_button_secondary' do
    subject(:markup) { helper.govuk_button_secondary('Save as draft') }

    it 'adds a secondary govuk button' do
      is_expected.to have_tag(:button, with: { class: 'govuk-button govuk-button--secondary', 'data-module': 'govuk-button' }, text: 'Save as draft')
    end
  end

  describe '#govuk_button_warning' do
    subject(:markup) { helper.govuk_button_warning('Delete account') }

    it 'adds a warning govuk button' do
      is_expected.to have_tag(:button, with: { class: 'govuk-button govuk-button--warning', 'data-module': 'govuk-button' }, text: 'Delete account')
    end
  end

  describe '#govuk_button_start' do
    subject(:markup) { helper.govuk_button_start('Start now', '#') }

    it 'adds a start govuk button' do
      is_expected.to have_tag(:a, with: { class: 'govuk-button govuk-button--start', 'data-module': 'govuk-button', draggable: 'false', role: 'button' }, text: 'Start now') do
        with_tag(:svg, with: { class: 'govuk-button__start-icon' })
      end
    end
  end

  describe '#govuk_link_button' do
    subject(:markup) { helper.govuk_link_button('Save and continue', '#') }

    it 'adds a default govuk link button' do
      is_expected.to have_tag(:a, with: { class: 'govuk-button', 'data-module': 'govuk-button', draggable: 'false', role: 'button' }, text: 'Save and continue')
    end

    context 'with custom classes' do
      subject(:markup) do
        helper.govuk_link_button('Save and continue', '#', class: 'my-custom-class1 my-custom-class2')
      end

      it 'adds a default govuk link button with custom classes' do
        is_expected.to have_tag(:a, with: { class: 'govuk-button my-custom-class1 my-custom-class2', 'data-module': 'govuk-button', draggable: 'false', role: 'button' }, text: 'Save and continue')
      end
    end
  end

  describe '#govuk_link_button_secondary' do
    subject(:markup) { helper.govuk_link_button_secondary('Save as draft', '#') }

    it 'adds a secondary govuk link button' do
      is_expected.to have_tag(:a, with: { class: 'govuk-button govuk-button--secondary', 'data-module': 'govuk-button', draggable: 'false', role: 'button' }, text: 'Save as draft')
    end
  end

  describe '#govuk_link_button_warning' do
    subject(:markup) { helper.govuk_link_button_warning('Delete account', '#') }

    it 'adds a warning govuk link button' do
      is_expected.to have_tag(:a, with: { class: 'govuk-button govuk-button--warning', 'data-module': 'govuk-button', draggable: 'false', role: 'button' }, text: 'Delete account')
    end
  end
end
