module DisableViewOnlyActions
  extend ActiveSupport::Concern

  included do
    before_action :disable_analytics, :disable_feedback_banner, :disable_flashes
  end

  def disable_analytics
    @disable_analytics = true
  end

  def disable_feedback_banner
    @disable_feedback_banner = true
  end

  def disable_flashes
    @disable_flashes = true
  end
end
