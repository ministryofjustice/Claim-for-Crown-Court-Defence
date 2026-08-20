# Ensure lib/omniauth maps to OmniAuth in Zeitwerk without changing global inflections.
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    'omniauth' => 'OmniAuth'
  )
end
