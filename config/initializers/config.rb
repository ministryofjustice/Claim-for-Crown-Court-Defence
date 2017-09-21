Config.setup do |config|
  # Name of the constant exposing loaded settings
  config.const_name = 'Settings'
  config.use_env = true
  config.env_prefix = 'SETTINGS'
  config.env_separator = '__'
  config.env_converter = :downcase

  # Ability to remove elements of the array set in earlier loaded settings file. For example value: '--'.
  #
  # config.knockout_prefix = nil

  # Parse numeric values as integers instead of strings.
  #
  # config.env_parse_values = false
end
