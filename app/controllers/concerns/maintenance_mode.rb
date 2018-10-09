module MaintenanceMode
  extend ActiveSupport::Concern

  included do
    before_action :handle_maintenance
  end

  private

  def handle_maintenance
    return unless maintenance_mode?
    store_location
    redirect_to maintenance_path
  end

  def maintenance_mode?
    ENV['MAINTENANCE_MODE'].present?
  end
end
