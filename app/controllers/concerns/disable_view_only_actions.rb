module DisableViewOnlyActions
  extend ActiveSupport::Concern

  included do
    before_action :disable_analytics, :disable_phase_banner, :disable_flashes
  end

  def disable_analytics
    GoogleAnalytics::DataTracking.active = false
  end

  def disable_phase_banner
    @disable_phase_banner = true
  end

  def disable_flashes
    @disable_flashes = true
  end
end
