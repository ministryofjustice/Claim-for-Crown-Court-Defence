module Advocates::ClaimsHelper
  def validation_error_message(resource, attribute)
    if resource.errors[attribute]
      content_tag :span, class: 'validation-error' do
        resource.errors[attribute].join(", ")
      end
    end
  end
end
