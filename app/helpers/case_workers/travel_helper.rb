# view helpers for travel automation features
# i.e. google map API
#
module CaseWorkers::TravelHelper
  def link_to_map(body, options = {})
    origin = options.delete(:origin)
    destination = options.delete(:destination)
    travelmode = options.delete(:travelmode) || 'driving'

    link_to(body, google_map_url(origin, destination, travelmode), options) if origin.present? && destination.present?
  end

  private

  def google_map_url(origin, destination, travelmode)
    "https://www.google.co.uk/maps/dir/?api=1&origin=#{origin}&destination=#{destination}&travelmode=#{travelmode}"
  end
end
