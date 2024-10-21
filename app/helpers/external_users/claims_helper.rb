module ExternalUsers::ClaimsHelper
  def claim_requires_dates_attended?(claim)
    case_type_codes = claim&.fee_scheme&.agfs_reform? ? %w[GRDIS GRGLT] : %w[GRTRL GRRTR GRDIS GRGLT]
    case_type_codes.include?(claim.case_type.fee_type_code)
  end

  def show_add_date_link?(fee)
    %w[trial retrial].include? fee.claim.case_type.name.downcase
  end

  def build_dates_attended?(fee)
    [
      ['discontinuance', 'guilty plea'].include?(fee.claim.case_type.name.downcase),
      !fee.claim.hardship?
    ].all?
  end

  def validation_error_message(error_presenter_or_resource, attribute)
    return if error_presenter_or_resource.nil?
    case error_presenter_or_resource
    when ErrorMessage::Presenter
      validation_message_from_presenter(error_presenter_or_resource, attribute)
    when ActiveModel::Errors
      validation_message_from_errors_hash(error_presenter_or_resource, attribute)
    else
      validation_message_from_resource(error_presenter_or_resource, attribute)
    end
  end

  def validation_message_from_presenter(presenter, attribute)
    if presenter.errors_for?(attribute.to_sym)
      tag.span(class: 'error error-message') do
        presenter.field_errors_for(attribute.to_sym)
      end
    else
      ''
    end
  end

  def validation_message_from_errors_hash(resource, attribute)
    if resource[attribute]
      tag.span(class: 'error error-message') do
        resource[attribute].join(', ')
      end
    else
      ''
    end
  end

  def validation_message_from_resource(resource, attribute)
    validation_message_from_errors_hash(resource.errors, attribute)
  end

  def error_class(presenter, *attributes)
    return if presenter.nil?
    options = { name: 'dropdown_field_with_errors' }.merge(attributes.extract_options!)
    options[:name] if attributes.detect { |att| presenter.field_errors_for(att.to_sym).present? }
  end

  def show_timed_retention_banner_to_user?
    current_user_is_external_user? &&
      current_user.setting?(:timed_retention_banner_seen).nil?
  end

  def show_hardship_claims_banner_to_user?
    Settings.hardship_claims_banner_enabled? &&
      current_user_is_external_user? &&
      current_user.setting?(:hardship_claims_banner_seen).nil?
  end

  def show_clair_contingency_banner_to_user?
    Settings.clair_contingency_banner_enabled? &&
      current_user_is_external_user? &&
      current_user.setting?(:clair_contingency_banner_seen).nil?
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

  def url_for_referrer(referrer, claim)
    return unless claim
    {
      'summary' => summary_external_users_claim_path(claim)
    }[referrer.to_s]
  end

  def reasonset_for_expense_type(expense_type)
    return ExpenseType::REASON_SET_A if expense_type.blank?
    expense_type.expense_reasons_hash
  end

  def trial_dates_fields_classes(show)
    return ['govuk-!-padding-top-7'] if show

    ['govuk-!-padding-top-7', 'hidden']
  end
end
