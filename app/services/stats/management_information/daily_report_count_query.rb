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

        @start_at = @date_range.first.iso8601
        @end_at = @date_range.last.iso8601
      end

      def call
        submission_queries + completion_queries
      end

      private

      def filter_by(date_column_filter)
        @query_set.each_with_object([]) do |(name, query), results|
          result = { name: name.to_s.humanize, filter: date_column_filter.to_s.humanize }

          query_results = query.call(start_at: @start_at,
                                     end_at: @end_at,
                                     date_column_filter: date_column_filter).to_a

          counts_by_day = query_results.map do |tuple|
            { tuple['day'].to_date.iso8601 => tuple['count'] }
          end.reduce(:merge)

          result.merge!(counts_by_day)
          results.append(result)
        end
      end

      def submission_queries
        filter_by(:originally_submitted_at)
      end

      def completion_queries
        filter_by(:completed_at)
      end
    end
  end
end
