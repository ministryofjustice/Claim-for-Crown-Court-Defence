# frozen_string_literal: true

RSpec.describe GovukComponent::LinkHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_back_link_to' do
    subject(:markup) { helper.govuk_back_link_to(*args) }

    context 'default component' do
      let(:args) { ['GovUK', 'https://www.gov.uk'] }

      it 'adds link with govuk class' do
        is_expected.to have_tag(:a, with: { class: 'govuk-back-link', href: 'https://www.gov.uk' }, text: 'GovUK')
      end
    end

    context 'with a custom class' do
      let(:args) { ['GovUK', 'https://www.gov.uk', { class: 'my-custom-class1 my-custom-class2' }] }

      it 'adds link with custom classes, prepended by govuk class' do
        is_expected.to have_tag(:a, with: { class: 'govuk-back-link my-custom-class1 my-custom-class2' })
      end
    end
  end

  describe '#govuk_header_link_to' do
    subject(:markup) { helper.govuk_header_link_to(*args) }

    context 'default component' do
      let(:args) { ['GovUK', 'https://www.gov.uk'] }

      it 'adds link with govuk class' do
        is_expected.to have_tag(:a, with: { class: 'govuk-header__link', href: 'https://www.gov.uk' }, text: 'GovUK')
      end
    end

    context 'with a custom class' do
      let(:args) { ['GovUK', 'https://www.gov.uk', { class: 'my-custom-class1 my-custom-class2' }] }

      it 'adds link with custom classes, prepended by govuk class' do
        is_expected.to have_tag(:a, with: { class: 'govuk-header__link my-custom-class1 my-custom-class2' })
      end
    end
  end

  describe '#govuk_link_to' do
    subject(:markup) { helper.govuk_link_to(*args) }

    context 'default component' do
      let(:args) { ['GovUK', 'https://www.gov.uk'] }

      it 'adds link with govuk class' do
        is_expected.to have_tag(:a, with: { class: 'govuk-link', href: 'https://www.gov.uk' }, text: 'GovUK')
      end
    end

    context 'with a custom class' do
      let(:args) { ['GovUK', 'https://www.gov.uk', { class: 'my-custom-class1 my-custom-class2' }] }

      it 'adds link with custom classes, prepended by govuk class' do
        is_expected.to have_tag(:a, with: { class: 'govuk-link my-custom-class1 my-custom-class2' })
      end
    end
  end

  describe '#govuk_mail_to' do
    subject(:markup) { helper.govuk_mail_to(*args) }

    context 'default component' do
      let(:args) { ['email@example.com', 'My link text'] }

      it 'adds email link with govuk class' do
        is_expected.to have_tag(:a, with: { class: 'govuk-link', href: 'mailto:email@example.com' }, text: 'My link text')
      end
    end

    context 'with a custom class' do
      let(:args) { ['email@example.com', 'My link text', { class: 'my-custom-class1 my-custom-class2' }] }

      it 'adds email link with custom classes, prepended by govuk class' do
        is_expected.to have_tag(:a, with: { class: 'govuk-link my-custom-class1 my-custom-class2' })
      end
    end
  end

  describe '#govuk_skip_link_to' do
    subject(:markup) { helper.govuk_skip_link_to(*args) }

    context 'default component' do
      let(:args) { ['GovUK', 'https://www.gov.uk'] }

      it 'adds link with govuk class' do
        is_expected.to have_tag(:a, with: { class: 'govuk-skip-link', href: 'https://www.gov.uk', 'data-module': 'govuk-skip-link' }, text: 'GovUK')
      end
    end

    context 'with a custom class' do
      let(:args) { ['GovUK', 'https://www.gov.uk', { class: 'my-custom-class1 my-custom-class2' }] }

      it 'adds link with custom classes, prepended by govuk class' do
        is_expected.to have_tag(:a, with: { class: 'govuk-skip-link my-custom-class1 my-custom-class2', 'data-module': 'govuk-skip-link' })
      end
    end
  end
end
