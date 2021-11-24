# frozen_string_literal: true

# Management information statistics
#
# Counts of records from the management information (V2)
# report filtered by various values, including a date. That
# date is specified as a range here.
#

Dir.glob(File.join(__dir__, 'concerns', '**', '*.rb')).each { |f| require_dependency f }
Dir.glob(File.join(__dir__, 'queries', '**', '*.rb')).each { |f| require_dependency f }

module Stats
  module ManagementInformation
    class DailyReportCountQuery
      def self.call(**kwargs)
        new(kwargs).call
      end

      def initialize(**kwargs)
        @query_set = kwargs[:query_set]
        @date_range = kwargs[:date_range]

        raise ArgumentError, 'query set must be provided' if @query_set.blank?
        raise ArgumentError, 'date range must be provided' if @date_range.blank?
      end

      def call
        submission_queries + completion_queries
      end

      private

      def queries(date_column_filter)
        @query_set.each_with_object([]) do |(name, query), results|
          result = { name: name.to_s.humanize, filter: date_column_filter.to_s.humanize }
          @date_range.each do |day|
            result[day.iso8601] = query.call(day: day.iso8601,
                                             date_column_filter: date_column_filter).first['count']
          end
          results.append(result)
        end
      end

      def submission_queries
        queries(:originally_submitted_at)
      end

      def completion_queries
        queries(:completed_at)
      end
    end
  end
end
