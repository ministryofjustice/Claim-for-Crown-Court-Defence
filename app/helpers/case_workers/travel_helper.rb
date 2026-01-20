# view helpers for travel automation features
# i.e. google map API
#
module CaseWorkers::TravelHelper
  def link_to_map(expense, options = {})
    @expense = expense
    @options = options
    @origin = @options.delete(:origin)
    @destination = @options.delete(:destination)

    govuk_link_to(link_text, google_map_url(@origin, @destination, travel_mode), @options) if can_link?
  end

  private

  def can_link?
    @origin.present? && @destination.present?
  end

  def link_text
    I18n.t(@expense.mileage_rate_id.eql?(2) ? 'view_public_transport_link' : 'view_car_journey_link')
  end

  def travel_mode
    @expense.mileage_rate_id.eql?(2) ? 'transit' : @options.delete(:travelmode) || 'driving'
  end

  def google_map_url(origin, destination, travelmode)
    "https://www.google.co.uk/maps/dir/?api=1&origin=#{origin}&destination=#{destination}&travelmode=#{travelmode}"
  end
end
