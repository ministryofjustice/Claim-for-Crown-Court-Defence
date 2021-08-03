# frozen_string_literal: true

module GovukComponent
  module SharedHelpers
    private

    def prepend_classes(classes_to_prepend, options = {})
      classes = options[:class].present? ? options[:class].split(' ') : []
      classes.prepend(classes_to_prepend.split(' '))
      options[:class] = classes.join(' ')
      options
    end

    def capture_or_arg(data = nil, &block)
      block ? capture(&block) : data
    end
  end
end
