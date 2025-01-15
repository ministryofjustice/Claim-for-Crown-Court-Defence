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
      output = proc do
        contents = yield
        # In Rails 7.0 DateTime#to_fs needs to be used instead of DateTime#to_s
        # to format the date according to the setting in config/locales/en.yml.
        # However, to_fs does not exist on all data types that can appear here.
        contents.respond_to?(:to_fs) ? contents.to_fs : contents&.to_s
      end
      capture(&output)
    end
  end
end
