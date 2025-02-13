# frozen_string_literal: true

# Component Reference: https://design-system.service.gov.uk/components/table/

module GovukComponent
  module TableHelpers
    def govuk_table(tag_options = {}, &)
      tag_options = prepend_classes('govuk-table app-table--responsive', tag_options)

      tag.table(capture(&), **tag_options)
    end

    def govuk_table_caption(tag_options = {}, &)
      tag_options = prepend_classes('govuk-table__caption', tag_options)

      tag.caption(capture(&), **tag_options)
    end

    def govuk_table_thead(tag_options = {}, &)
      tag_options = prepend_classes('govuk-table__head', tag_options)

      tag.thead(capture(&), **tag_options)
    end

    def govuk_table_tbody(tag_options = {}, &)
      tag_options = prepend_classes('govuk-table__body', tag_options)

      tag.tbody(capture(&), **tag_options)
    end

    def govuk_table_tfoot(tag_options = {}, &)
      tag_options = prepend_classes('govuk-table__foot', tag_options)

      tag.tfoot(capture(&), **tag_options)
    end

    def govuk_table_row(tag_options = {}, &)
      tag_options = prepend_classes('govuk-table__row', tag_options)

      tag.tr(capture(&), **tag_options)
    end

    def govuk_table_th(tag_options = {}, &)
      tag_options = prepend_classes('govuk-table__header', tag_options)
      tag_options[:scope] = tag_options[:scope].presence || 'col'

      tag.th(capture(&), **tag_options)
    end

    def govuk_table_th_numeric(tag_options = {}, &)
      tag_options = prepend_classes('govuk-table__header govuk-table__header--numeric', tag_options)
      tag_options[:scope] = tag_options[:scope].presence || 'col'

      tag.th(capture(&), **tag_options)
    end

    def govuk_table_td(tag_options = {}, &)
      tag_options = prepend_classes('govuk-table__cell', tag_options)

      tag.td(capture(&), **tag_options)
    end

    def govuk_table_td_numeric(tag_options = {}, &)
      tag_options = prepend_classes('govuk-table__cell govuk-table__cell--numeric', tag_options)

      tag.td(capture(&), **tag_options)
    end

    def govuk_table_and_caption(caption = nil, tag_options = {}, &)
      govuk_table do
        concat(govuk_table_caption(tag_options) { caption })
        concat(capture(&))
      end
    end

    def govuk_table_thead_collection(data_collections)
      govuk_table_thead do
        govuk_table_row do
          data_collections.each do |datum|
            concat(govuk_table_th { datum })
          end
        end
      end
    end

    def govuk_table_row_collection(data_collections)
      govuk_table_row do
        data_collections.each do |datum|
          concat(govuk_table_td { datum })
        end
      end
    end
  end
end
