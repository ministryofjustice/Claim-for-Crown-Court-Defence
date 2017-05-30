module FeedbackHelper
  def referrer_is_claim?(referrer)
    referrer =~ /claims/
  end
end
