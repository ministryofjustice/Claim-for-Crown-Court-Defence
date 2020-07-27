# frozen_string_literal: true

RSpec.describe GovukComponent::WarningTextHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_warning_text' do
    subject(:markup) { helper.govuk_warning_text('You can be fined up to £5,000 if you do not register.') }

    it 'adds tag with govuk class' do
      is_expected.to have_tag(:div, with: { class: 'govuk-warning-text' })
    end

    it 'adds nested span tag with govuk class' do
      is_expected.to have_tag(:div) do
        with_tag(:span, with: { class: 'govuk-warning-text__icon', 'aria-hidden': true })
      end
    end

    it 'adds nested strong tag with govuk class' do
      is_expected.to have_tag(:div) do
        with_tag(:strong, with: { class: 'govuk-warning-text__text'})
      end
    end

    it 'adds nested span in strong tag with govuk class' do
      is_expected.to have_tag(:div) do
        with_tag(:strong) do
          with_tag(:span, with: { class: 'govuk-warning-text__assistive' })
        end
      end
    end

    it 'yields content to nested strong tag' do
      is_expected.to have_tag(:div) do
        with_tag(:strong) do
          with_text /You can be fined up to £5,000 if you do not register/
        end
      end
    end

    context 'with custom classes' do
      subject(:markup) do
        helper.govuk_warning_text('You can be fined up to £5,000 if you do not register.', class: 'my-custom-class1 my-custom-class2')
      end

      it 'adds tag with custom classes, prepended by govuk class' do
        is_expected.to have_tag(:div, with: { class: 'govuk-warning-text my-custom-class1 my-custom-class2' })
      end
    end
  end
end
