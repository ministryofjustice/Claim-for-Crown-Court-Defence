# frozen_string_literal: true

module GovukComponent
  module InsetTextHelpers
    def govuk_inset_text(tag_options = {}, &)
      tag_options = prepend_classes('govuk-inset-text', tag_options)
      content = capture(&)

      tag.div(content, **tag_options)
    end
  end
end
