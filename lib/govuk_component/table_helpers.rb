# frozen_string_literal: true

module GovukComponent
  module TableHelpers
    def govuk_table(**tag_options, &block)
      tag_options = prepend_classes('govuk-table', tag_options)
      table_block = capture(&block)

      tag.table(table_block, tag_options)
    end

    def govuk_table_caption(**tag_options, &block)
      tag_options = prepend_classes('govuk-table__caption', tag_options)
      caption_block = capture(&block)

      tag.caption(caption_block, tag_options)
    end

    def govuk_table_thead(**tag_options, &block)
      tag_options = prepend_classes('govuk-table__head', tag_options)
      thead_block = capture(&block)

      tag.thead(tag_options) do
        govuk_table_row do
          thead_block
        end
      end
    end

    def govuk_table_tbody(**tag_options, &block)
      tag_options = prepend_classes('govuk-table__body', tag_options)
      tbody_block = capture(&block)

      tag.tbody(tbody_block, tag_options)
    end

    def govuk_table_tfoot(**tag_options, &block)
      tag_options = prepend_classes('govuk-table__foot', tag_options)
      thead_block = capture(&block)

      tag.tfoot(tag_options) do
        govuk_table_row do
          thead_block
        end
      end
    end

    def govuk_table_row(**tag_options, &block)
      tag_options = prepend_classes('govuk-table__row', tag_options)
      tr_block = capture(&block)

      tag.tr(tr_block, tag_options)
    end

    def govuk_table_th(row = false, numeric = false, width = nil, **tag_options, &block)
      klass = 'govuk-table__header'
      klass += ' govuk-table__header--numeric' if numeric
      klass += " govuk-!-width-#{width}" if width.present?
      tag_options = prepend_classes(klass, tag_options)
      tag_options[:scope] = 'row' if row

      th_block = capture(&block)
      tag.th(th_block, tag_options)
    end

    def govuk_table_td(numeric = false, **tag_options, &block)
      klass = 'govuk-table__cell'
      klass += ' govuk-table__cell--numeric' if numeric
      tag_options = prepend_classes(klass, tag_options)

      td_block = capture(&block)
      tag.td(td_block, tag_options)
    end
  end
end
