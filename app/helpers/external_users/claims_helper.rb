module ExternalUsers::ClaimsHelper
  def validation_error_message(error_presenter_or_resource, attribute)
    return if error_presenter_or_resource.nil?
    if error_presenter_or_resource.is_a?(ErrorPresenter)
      validation_message_from_presenter(error_presenter_or_resource, attribute)
    else
      validation_message_from_resource(error_presenter_or_resource, attribute)
    end
  end

  def validation_message_from_presenter(presenter, attribute)
    content_tag :span, class: 'validation-error' do
      presenter.field_level_error_for(attribute.to_sym)
    end
  end

  def validation_message_from_resource(resource, attribute)
    if resource.errors[attribute]
      content_tag :span, class: 'validation-error' do
        resource.errors[attribute].join(", ")
      end
    end
  end

  def gov_uk_date_field_error_messages(presenter, attribute)
    return if presenter.nil? || !presenter.is_a?(ErrorPresenter)
    presenter.field_level_error_for(attribute.to_sym).split(',').each { |e| e.strip! }
  end
end
