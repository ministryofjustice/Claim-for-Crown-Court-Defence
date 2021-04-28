# frozen_string_literal: true

GoogleMaps::Directions.configure do |config|
  config.api_key = ENV['GOOGLE_API_KEY']
  config.default_options = { region: 'uk', alternatives: true }
end
