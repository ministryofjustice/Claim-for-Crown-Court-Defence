module ExternalUsers::ClaimsHelper
  def validation_error_message(error_presenter_or_resource, attribute)
    return if error_presenter_or_resource.nil?
    case error_presenter_or_resource
    when ErrorPresenter
      validation_message_from_presenter(error_presenter_or_resource, attribute)
    when ActiveModel::Errors
      validation_message_from_errors_hash(error_presenter_or_resource, attribute)
    else
      validation_message_from_resource(error_presenter_or_resource, attribute)
    end
  end

  def validation_message_from_presenter(presenter, attribute)
    if presenter.errors_for?(attribute.to_sym)
      content_tag :span, class: 'error' do
        presenter.field_level_error_for(attribute.to_sym)
      end
    else
      ''
    end
  end

  def validation_message_from_errors_hash(resource, attribute)
    if resource[attribute]
      content_tag :span, class: 'error' do
        resource[attribute].join(', ')
      end
    else
      ''
    end
  end

  def validation_message_from_resource(resource, attribute)
    validation_message_from_errors_hash(resource.errors, attribute)
  end

  def gov_uk_date_field_error_messages(presenter, attribute)
    return if presenter.nil? || !presenter.is_a?(ErrorPresenter)
    presenter.field_level_error_for(attribute.to_sym).split(',').each(&:strip!)
  end

  def error_class?(presenter, *attributes)
    return if presenter.nil?
    options = { name: 'dropdown_field_with_errors' }.merge(attributes.extract_options!)
    options[:name] if attributes.detect { |att| presenter.field_level_error_for(att.to_sym).present? }
  end

  def show_timed_retention_banner_to_user?
    Settings.timed_retention_banner_enabled? &&
      current_user_is_external_user? &&
      current_user.setting?(:timed_retention_banner_seen).nil?
  end

  def supplier_number_hint
    if current_user.persona.admin?
      path = edit_external_users_admin_provider_path(current_user.provider)
      "You can add more LGFS supplier numbers on the #{link_to 'Manage provider', path} page".html_safe
    else
      'Admin users can add more LGFS supplier numbers on the Manage provider page'
    end
  end

  def external_users_claim_path_for_state(claim)
    claim.draft? ? summary_external_users_claim_path(claim) : external_users_claim_path(claim)
  end
end
