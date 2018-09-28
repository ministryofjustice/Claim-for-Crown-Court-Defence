# view helpers for travel automation features
# i.e. google map API
#
module CaseWorkers::TravelHelper
  def link_to_map(body, options = {})
    origin = options.delete(:origin)
    destination = options.delete(:destination)
    travelmode = options.delete(:travelmode) || 'driving'
    if origin.present? && destination.present?
      url = "https://www.google.co.uk/maps/dir/?api=1&origin=#{origin}&destination=#{destination}&travelmode=#{travelmode}"
      link_to(body, url, options)
    end
  end
end
