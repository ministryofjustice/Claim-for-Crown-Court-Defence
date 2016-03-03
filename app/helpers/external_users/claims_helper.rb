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


  def url_for_external_users_claim(claim)
    claim.persisted? ? external_users_claim_path(claim) : external_users_claims_path
  end

  def litigator_claim?
    @claim.is_a? Claim::LitigatorClaim
  end

  def advocate_claim?
    @claim.is_a? Claim::AdvocateClaim
  end
end
