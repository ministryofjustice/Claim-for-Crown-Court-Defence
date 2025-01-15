# frozen_string_literal: true

RSpec.describe GovukComponent::SummaryListHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_summary_list' do
    subject(:markup) { helper.govuk_summary_list {} }

    it 'adds dl tag with govuk class' do
      is_expected.to have_tag(:dl, with: { class: 'govuk-summary-list' })
    end

    context 'with custom classes' do
      subject(:markup) { helper.govuk_summary_list(class: 'my-custom-class') {} }

      it 'adds dl tag with custom class, prepended by govuk class' do
        is_expected.to have_tag(:dl, with: { class: 'govuk-summary-list my-custom-class' })
      end
    end
  end

  describe '#govuk_summary_list_no_border' do
    subject(:markup) { helper.govuk_summary_list_no_border {} }

    it 'adds dl tag with govuk classes' do
      is_expected.to have_tag(:dl, with: { class: 'govuk-summary-list govuk-summary-list--no-border' })
    end

    context 'with custom classes' do
      subject(:markup) { helper.govuk_summary_list_no_border(class: 'my-custom-class') {} }

      it 'adds dl tag with custom class, prepended by govuk classes' do
        is_expected.to have_tag(:dl,
                                with: { class: 'govuk-summary-list govuk-summary-list--no-border my-custom-class' })
      end
    end
  end

  describe '#govuk_summary_list_row' do
    subject(:markup) { helper.govuk_summary_list_row {} }

    it 'adds div tag with govuk class' do
      is_expected.to have_tag(:div, with: { class: 'govuk-summary-list__row' })
    end

    context 'with custom classes' do
      subject(:markup) { helper.govuk_summary_list_row(class: 'my-custom-class') {} }

      it 'adds div tag with custom class, prepended by govuk class' do
        is_expected.to have_tag(:div, with: { class: 'govuk-summary-list__row my-custom-class' })
      end
    end
  end

  describe '#govuk_summary_list_key' do
    subject(:markup) { helper.govuk_summary_list_key {} }

    it 'adds dt tag with govuk class' do
      is_expected.to have_tag(:dt, with: { class: 'govuk-summary-list__key' })
    end

    context 'with custom classes' do
      subject(:markup) { helper.govuk_summary_list_key(class: 'my-custom-class') {} }

      it 'adds dt tag with custom class, prepended by govuk class' do
        is_expected.to have_tag(:dt, with: { class: 'govuk-summary-list__key my-custom-class' })
      end
    end
  end

  describe '#govuk_summary_list_value' do
    subject(:markup) { helper.govuk_summary_list_value {} }

    it 'adds dd tag with govuk class' do
      is_expected.to have_tag(:dd, with: { class: 'govuk-summary-list__value' })
    end

    context 'with custom classes' do
      subject(:markup) { helper.govuk_summary_list_value(class: 'my-custom-class') {} }

      it 'adds dd tag with custom class, prepended by govuk class' do
        is_expected.to have_tag(:dd, with: { class: 'govuk-summary-list__value my-custom-class' })
      end
    end
  end

  describe '#govuk_summary_list_action' do
    subject(:markup) { helper.govuk_summary_list_action {} }

    it 'adds dd tag with govuk class' do
      is_expected.to have_tag(:dd, with: { class: 'govuk-summary-list__actions' })
    end

    context 'with custom classes' do
      subject(:markup) { helper.govuk_summary_list_action(class: 'my-custom-class') {} }

      it 'adds dd tag with custom class, prepended by govuk class' do
        is_expected.to have_tag(:dd, with: { class: 'govuk-summary-list__actions my-custom-class' })
      end
    end
  end

  describe '#govuk_summary_list_row_collection' do
    subject(:markup) { helper.govuk_summary_list_row_collection('Name', 'Sarah Philips', 'Edit') }

    it 'adds nested dt and dd tags within a div tag with govuk classes' do
      is_expected.to have_tag(:div, with: { class: 'govuk-summary-list__row' }) do
        with_tag(:dt, with: { class: 'govuk-summary-list__key' }, text: 'Name')
        with_tag(:dd, with: { class: 'govuk-summary-list__value' }, text: 'Sarah Philips')
        with_tag(:dd, with: { class: 'govuk-summary-list__actions' }, text: 'Edit')
      end
    end

    context 'without actions' do
      subject(:markup) { helper.govuk_summary_list_row_collection('Name', 'Sarah Philips', nil) }

      it 'does not print dd with class name govuk-summary-list__actions' do
        is_expected.not_to have_tag(:dd, with: { class: 'govuk-summary-list__actions' })
      end
    end

    context 'with custom classes' do
      subject(:markup) {
        helper.govuk_summary_list_row_collection('Name', 'Sarah Philips', 'Edit', class: 'my-custom-class')
      }

      it 'adds nested dt and dd tags within a div tag with custom class, prepended by govuk class' do
        is_expected.to have_tag(:div, with: { class: 'govuk-summary-list__row my-custom-class' }) do
          with_tag(:dt, with: { class: 'govuk-summary-list__key' }, text: 'Name')
          with_tag(:dd, with: { class: 'govuk-summary-list__value' }, text: 'Sarah Philips')
          with_tag(:dd, with: { class: 'govuk-summary-list__actions' }, text: 'Edit')
        end
      end
    end

    context 'when passed a plain ruby block' do
      subject(:markup) { helper.govuk_summary_list_row_collection('Name', nil, 'Edit') { value } }

      context 'with a String' do
        let(:value) { 'Foobar' }

        it 'casts to string' do
          is_expected.to have_tag(:div) do
            with_tag(:dd, with: { class: 'govuk-summary-list__value' }, text: 'Foobar')
          end
        end
      end

      context 'with an integer' do
        let(:value) { 101 }

        it 'casts to string' do
          is_expected.to have_tag(:div) do
            with_tag(:dd, with: { class: 'govuk-summary-list__value' }, text: '101')
          end
        end
      end

      context 'with a date' do
        let(:value) { Date.new(2001, 2, 25) }

        it 'casts to string' do
          is_expected.to have_tag(:div) do
            with_tag(:dd, with: { class: 'govuk-summary-list__value' }, text: '25/02/2001 00:00')
          end
        end
      end
    end
  end
end
