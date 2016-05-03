class ExternalUsers::ApplicationController < ApplicationController
  before_action :authenticate_external_user!

  helper_method :url_for_external_users_claim
  helper_method :url_for_edit_external_users_claim

  def url_for_external_users_claim(claim)
    if claim.agfs?
      claim.persisted? ? advocates_claim_path(claim) : advocates_claims_path
    elsif claim.lgfs?
      claim.persisted? ? litigators_claim_path(claim) : litigators_claims_path
    elsif claim.interim?
      claim.persisted? ? litigators_interim_claim_path(claim) : litigators_interim_claims_path
    elsif claim.transfer?
      claim.persisted? ? litigators_transfer_claim_path(claim) : litigators_transfer_claims_path
    end
  end

  def url_for_edit_external_users_claim(claim)
    if claim.agfs?
      edit_advocates_claim_path(claim)
    elsif claim.lgfs?
      edit_litigators_claim_path(claim)
    elsif claim.interim?
      edit_litigators_interim_claim_path(claim)
    elsif claim.transfer?
      edit_litigators_transfer_claim_path(claim)
    end
  end

private

  def authenticate_external_user!
    unless user_signed_in? && current_user.persona.is_a?(ExternalUser)
      redirect_to root_path_url_for_user, alert: t('requires_external_user_authorisation')
    end
  end

  def date_attributes_for(date_param)
    date_params = []
    %w(dd mm yyyy).each do |part|
      date_params.push("#{date_param}_#{part}".to_sym)
    end
    date_params
  end

  def common_dates_attended_attributes
    { dates_attended_attributes: [
          :id,
          :fee_id,
          date_attributes_for(:date),
          date_attributes_for(:date_to),
          :_destroy
        ]
    }
  end

  def common_fees_attributes
     [
       :id,
       :claim_id,
       :fee_type_id,
       :sub_type_id,
       :fee_id,
       :quantity,
       :rate,
       :amount,
       :case_numbers,
       :_destroy,
       common_dates_attended_attributes
      ]
  end

end
