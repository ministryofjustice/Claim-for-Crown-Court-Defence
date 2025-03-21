# frozen_string_literal: true

RSpec.describe GovukComponent::TagHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_tag' do
    subject(:markup) { helper.govuk_tag('Tag') }

    it 'adds tag with govuk class' do
      is_expected.to have_tag(:strong, with: { class: 'govuk-tag' })
    end

    it 'yields content to strong tag' do
      is_expected.to have_tag(:strong, text: 'Tag')
    end

    context 'with color' do
      subject(:markup) do
        helper.govuk_tag('Tag', 'green')
      end

      it 'adds tag with color class, prepended by govuk class' do
        is_expected.to have_tag(:strong, with: { class: 'govuk-tag govuk-tag--green' })
      end
    end

    context 'with custom classes' do
      subject(:markup) do
        helper.govuk_tag('Tag', class: 'my-custom-class1 my-custom-class2')
      end

      it 'adds tag with custom classes, prepended by govuk class' do
        is_expected.to have_tag(:strong, with: { class: 'govuk-tag my-custom-class1 my-custom-class2' })
      end
    end
  end

  describe '#govuk_tag_active_user?' do
    it 'responds to govuk_tag_active_user?' do
      expect(helper).to respond_to(:govuk_tag_active_user?)
    end

    context 'when external user is inactive' do
      subject { helper.govuk_tag_active_user?(user) }

      let(:user) { create(:user, :active, :disabled) }
      let(:tag_class) { 'govuk-tag govuk-tag--red' }
      let(:tag_text) { 'Inactive' }

      it { is_expected.to have_tag(:strong, with: { class: tag_class }, text: tag_text) }
    end

    context 'when external user is active' do
      subject { helper.govuk_tag_active_user?(user) }

      let(:user) { create(:user, :active, :enabled) }
      let(:tag_class) { 'govuk-tag govuk-tag--green' }
      let(:tag_text) { 'Active' }

      it { is_expected.to have_tag(:strong, with: { class: tag_class }, text: tag_text) }
    end
  end
end
