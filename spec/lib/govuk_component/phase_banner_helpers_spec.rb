# frozen_string_literal: true

RSpec.describe GovukComponent::PhaseBannerHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_phase_banner' do
    subject(:markup) { helper.govuk_phase_banner('alpha', 'This is a new service') }

    it 'adds phase-banner with govuk class' do
      is_expected.to have_tag(:div, with: { class: 'govuk-phase-banner' })
    end

    it 'adds nested p tag with govuk class' do
      is_expected.to have_tag(:div) do
        with_tag(:p, with: { class: 'govuk-phase-banner__content' })
      end
    end

    it 'adds nested strong in p tag with govuk class' do
      is_expected.to have_tag(:div) do
        with_tag(:p) do
          with_tag(:strong, with: { class: 'govuk-tag govuk-phase-banner__content__tag' })
        end
      end
    end

    it 'adds content__tag to nested strong' do
      is_expected.to have_tag(:div) do
        with_tag(:p) do
          with_tag(:strong, text: 'alpha')
        end
      end
    end

    it 'adds nested span in p tag with govuk class' do
      is_expected.to have_tag(:div) do
        with_tag(:p) do
          with_tag(:span, with: { class: 'govuk-phase-banner__text' })
        end
      end
    end

    it 'adds banner__text to nested span' do
      is_expected.to have_tag(:div) do
        with_tag(:p) do
          with_tag(:span, text: 'This is a new service')
        end
      end
    end

    context 'without a phase' do
      subject(:markup) { helper.govuk_phase_banner('', 'This is a new service') }

      it 'adds phase-banner without a content__tag' do
        is_expected.not_to have_tag(:strong, with: { class: 'govuk-tag govuk-phase-banner__content__tag' })
      end
    end

    context 'with custom classes' do
      subject(:markup) do
        helper.govuk_phase_banner('alpha', 'This is a new service', class: 'my-custom-class1 my-custom-class2')
      end

      it 'adds phase-banner with custom classes, prepended by govuk class' do
        is_expected.to have_tag(:div, with: { class: 'govuk-phase-banner my-custom-class1 my-custom-class2' })
      end
    end
  end
end
