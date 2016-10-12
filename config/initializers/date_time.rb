# Date
Date::DATE_FORMATS[:default] = Settings.date_format

# Time
DateTime::DATE_FORMATS[:default] = Settings.date_time_format

# Time
Time::DATE_FORMATS[:default] = Settings.date_time_format

# Instead of 2013-07-23T01:18:32.000Z
# Will produce 2013-07-23T01:18:32Z
ActiveSupport::JSON::Encoding.time_precision = 0
