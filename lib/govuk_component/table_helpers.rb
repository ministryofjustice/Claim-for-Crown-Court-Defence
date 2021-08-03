# frozen_string_literal: true

# Component Reference: https://design-system.service.gov.uk/components/table/

module GovukComponent
  module TableHelpers
    def govuk_table(tag_options = {}, &block)
      tag_options = prepend_classes('govuk-table', tag_options)
      capture_block = capture(&block)

      tag.table(capture_block, tag_options)
    end

    def govuk_table_caption(caption = nil, tag_options = {}, &block)
      tag_options = prepend_classes('govuk-table__caption', tag_options)
      content = capture_or_arg(caption, &block)

      tag.caption(content, tag_options)
    end

    def govuk_table_thead(tag_options = {}, &block)
      tag_options = prepend_classes('govuk-table__head', tag_options)
      capture_block = capture(&block)

      tag.thead(capture_block, tag_options)
    end

    def govuk_table_tbody(tag_options = {}, &block)
      tag_options = prepend_classes('govuk-table__body', tag_options)
      capture_block = capture(&block)

      tag.tbody(capture_block, tag_options)
    end

    def govuk_table_row(tag_options = {}, &block)
      tag_options = prepend_classes('govuk-table__row', tag_options)
      capture_block = capture(&block)

      tag.tr(capture_block, tag_options)
    end

    def govuk_table_th(data = nil, scope = 'col', tag_options = {}, &block)
      tag_options = prepend_classes('govuk-table__header', tag_options)
      tag_options[:scope] = scope
      content = capture_or_arg(data, &block)

      tag.th(content, tag_options)
    end

    def govuk_table_td(data = nil, tag_options = {}, &block)
      tag_options = prepend_classes('govuk-table__cell', tag_options)
      content = capture_or_arg(data, &block)

      tag.td(content, tag_options)
    end

    def govuk_table_and_caption(caption = nil, tag_options = {}, &block)
      govuk_table do
        concat govuk_table_caption(caption, tag_options)
        concat capture(&block)
      end
    end

    def govuk_table_thead_collection(headers, _tag_options = {})
      govuk_table_thead do
        govuk_table_row do
          headers.each do |header|
            concat govuk_table_th(header)
          end
        end
      end
    end

    def govuk_table_tbody_collection(data_collections, _tag_options = {})
      govuk_table_tbody do
        table_rows = data_collections.map do |data|
          data.map do |datum|
            govuk_table_td(datum)
          end.join
        end

        table_rows.each do |table_cell|
          # rubocop:disable Rails/OutputSafety
          concat tag.tr(table_cell.html_safe, class: 'govuk-table__row')
          # rubocop:enable Rails/OutputSafety
        end
      end
    end
  end
end
