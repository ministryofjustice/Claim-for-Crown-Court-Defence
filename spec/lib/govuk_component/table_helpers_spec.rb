# frozen_string_literal: true

RSpec.describe GovukComponent::TableHelpers, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_table' do
    subject(:markup) { helper.govuk_table(class: 'my-custom-class') { nil } }

    it 'adds a govuk table' do
      is_expected.to have_tag(:table, with: { class: 'govuk-table app-table--responsive my-custom-class' })
    end
  end

  describe '#govuk_table_caption' do
    subject(:markup) { helper.govuk_table_caption(class: 'my-custom-class') { 'My table caption' } }

    it 'adds a govuk table caption' do
      is_expected.to have_tag(:caption, with: { class: 'govuk-table__caption my-custom-class' },
                                        text: 'My table caption')
    end
  end

  describe '#govuk_table_thead' do
    subject(:markup) { helper.govuk_table_thead(class: 'my-custom-class') { nil } }

    it 'adds a govuk table thead' do
      is_expected.to have_tag(:thead, with: { class: 'govuk-table__head my-custom-class' })
    end
  end

  describe '#govuk_table_tbody' do
    subject(:markup) { helper.govuk_table_tbody(class: 'my-custom-class') { nil } }

    it 'adds a govuk table tbody' do
      is_expected.to have_tag(:tbody, with: { class: 'govuk-table__body my-custom-class' })
    end
  end

  describe '#govuk_table_tfoot' do
    subject(:markup) { helper.govuk_table_tfoot(class: 'my-custom-class') { nil } }

    it 'adds a govuk table tfoot' do
      is_expected.to have_tag(:tfoot, with: { class: 'govuk-table__foot my-custom-class' })
    end
  end

  describe '#govuk_table_row' do
    subject(:markup) { helper.govuk_table_row(class: 'my-custom-class') { nil } }

    it 'adds a govuk table row' do
      is_expected.to have_tag(:tr, with: { class: 'govuk-table__row my-custom-class' })
    end
  end

  describe '#govuk_table_th' do
    context 'with col scope' do
      subject(:markup) { helper.govuk_table_th { 'table head' } }

      it 'adds a govuk table header cell' do
        is_expected.to have_tag(:th, with: { class: 'govuk-table__header', scope: 'col' }, text: 'table head')
      end
    end

    context 'with row scope' do
      subject(:markup) { helper.govuk_table_th(scope: 'row') { 'table head' } }

      it 'adds a govuk table header cell' do
        is_expected.to have_tag(:th, with: { class: 'govuk-table__header', scope: 'row' }, text: 'table head')
      end
    end

    context 'with custom class' do
      subject(:markup) { helper.govuk_table_th(scope: 'row', class: 'my-custom-class') { 'table head' } }

      it 'adds a govuk table header cell' do
        is_expected.to have_tag(:th, with: { class: 'govuk-table__header my-custom-class', scope: 'row' },
                                     text: 'table head')
      end
    end
  end

  describe '#govuk_table_th_numeric' do
    context 'with col scope' do
      subject(:markup) { helper.govuk_table_th_numeric { 'table head' } }

      it 'adds a govuk table header cell' do
        is_expected.to have_tag(:th, with: { class: 'govuk-table__header govuk-table__header--numeric', scope: 'col' },
                                     text: 'table head')
      end
    end

    context 'with row scope' do
      subject(:markup) { helper.govuk_table_th_numeric(scope: 'row') { 'table head' } }

      it 'adds a govuk table header cell' do
        is_expected.to have_tag(:th, with: { class: 'govuk-table__header govuk-table__header--numeric', scope: 'row' },
                                     text: 'table head')
      end
    end

    context 'with custom class' do
      subject(:markup) { helper.govuk_table_th_numeric(class: 'custom-class') { 'table head' } }

      it 'adds a govuk table header cell' do
        is_expected.to have_tag(:th, with: { class: 'govuk-table__header govuk-table__header--numeric custom-class' },
                                     text: 'table head')
      end
    end
  end

  describe '#govuk_table_td' do
    subject(:markup) { helper.govuk_table_td(class: 'my-custom-class') { 'table cell' } }

    it 'adds a govuk table cell' do
      is_expected.to have_tag(:td, with: { class: 'govuk-table__cell my-custom-class' }, text: 'table cell')
    end
  end

  describe '#govuk_table_td_numeric' do
    subject(:markup) { helper.govuk_table_td_numeric(class: 'my-custom-class') { 'table cell' } }

    it 'adds a govuk table cell' do
      is_expected.to have_tag(:td, with: { class: 'govuk-table__cell govuk-table__cell--numeric my-custom-class' },
                                   text: 'table cell')
    end
  end

  describe '#govuk_table_and_caption' do
    subject(:markup) { helper.govuk_table_and_caption('My table caption', class: 'my-custom-class') { nil } }

    it 'adds a nested caption in govuk table' do
      is_expected.to have_tag(:table, with: { class: 'govuk-table' }) do
        with_tag(:caption, with: { class: 'govuk-table__caption my-custom-class' }, text: 'My table caption')
      end
    end
  end

  describe '#govuk_table_thead_collection' do
    subject(:markup) do
      helper.govuk_table_thead_collection(['table head 1', 'table head 2'])
    end

    it 'adds a nested table header cell in govuk table head' do
      is_expected.to have_tag(:thead, with: { class: 'govuk-table__head' }) do
        with_tag(:tr, with: { class: 'govuk-table__row' }) do
          with_tag(:th, with: { class: 'govuk-table__header', scope: 'col' }, count: 2, text: /table head/)
        end
      end
    end
  end

  describe '#govuk_table_row_collection' do
    subject(:markup) do
      helper.govuk_table_row_collection(['data cell 1', 'data cell 2'])
    end

    it 'adds a nested table cells in govuk table row' do
      is_expected.to have_tag(:tr, with: { class: 'govuk-table__row' }) do
        with_tag(:td, with: { class: 'govuk-table__cell' }, count: 2, text: /data cell/)
      end
    end
  end
end
