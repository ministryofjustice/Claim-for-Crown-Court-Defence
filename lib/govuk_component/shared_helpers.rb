# frozen_string_literal: true

module GovukComponent
  module SharedHelpers
    private

    def prepend_classes(classes_to_prepend, options = {})
      classes = options[:class].present? ? options[:class].split : []
      classes.prepend(classes_to_prepend.split)
      options[:class] = classes.join(' ')
      options
    end

    def capture_output
      output = proc { yield&.to_s }
      capture(&output)
    end
  end
end
