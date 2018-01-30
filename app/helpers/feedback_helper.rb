module FeedbackHelper
  def referrer_is_claim?(referrer)
    referrer =~ /claims/
  end

  def cannot_identify_user?
    params[:user_id].blank? && current_user.blank?
  end
end
