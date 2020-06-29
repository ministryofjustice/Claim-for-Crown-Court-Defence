# frozen_string_literal: true

module GovukComponent
  module PanelHelpers
    def govuk_panel(title = nil, body = nil, tag_options = {})
      tag_options = prepend_classes('govuk-panel govuk-panel--confirmation', tag_options)

      tag.div(tag_options) do
        concat tag.h1(sanitize(title), class: 'govuk-panel__title')
        concat tag.div(sanitize(body), class: 'govuk-panel__body')
      end
    end

    private

    def prepend_classes(classes_to_prepend, options = {})
      classes = options[:class].present? ? options[:class].split(' ') : []
      classes.prepend(classes_to_prepend.split(' '))
      options[:class] = classes.join(' ')
      options
    end
  end
end
