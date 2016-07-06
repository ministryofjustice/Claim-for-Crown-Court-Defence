module Stats
  module Collector

    # This class counts the number of claims authorised to day that where the caseworker requested extra information vs the number
    # that were authorised without further info being needed.
    #
    class BaseCollector

      STRFTIME_MASK = '%Y-%m-%d %H:%M:%S.%6N'.freeze
      SECONDS_IN_DAY = 60 * 60 * 24

      def initialize(date = Date.today)
        @date = date
        @beginning_of_day = @date.beginning_of_day.utc.strftime(STRFTIME_MASK)
        @end_of_day = @date.end_of_day.utc.strftime(STRFTIME_MASK)
      end

      def collect
        # implement in sub class
      end
    end

  end
end