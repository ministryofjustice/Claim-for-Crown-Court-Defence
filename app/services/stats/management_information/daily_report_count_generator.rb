# frozen_string_literal: true

require 'csv'

module Stats
  module ManagementInformation
    class DailyReportCountGenerator
      include StuffLogger

      def self.call(**kwargs)
        new(kwargs).call
      end

      def initialize(**kwargs)
        @query_set = kwargs[:query_set]
        @start_at = kwargs[:start_at]
        @duration = kwargs[:duration] || (1.month - 1.day)

        raise ArgumentError, 'start_at must be provided' if @start_at.blank?
      end

      def call
        output = generate_report
        Stats::Result.new(output, :csv)
      end

      private

      def generate_report
        log_info('MI statistics generation started...')
        content = generate_csv
        log_info('MI statistics generation finished')
        content
      rescue StandardError => e
        log_error(e, 'MI statistics generation finished')
        raise
      end

      def generate_csv
        CSV.generate do |csv|
          aggregations.each_with_index do |rec, idx|
            csv << headers_for(rec) if idx.zero?
            csv << rec.values
          end
        end
      end

      def aggregations
        @aggregations ||= DailyReportCountQuery.call(query_set: @query_set, date_range: date_range)
      end

      def headers_for(rec)
        keys = rec.keys.map { |k| k.to_s.humanize }

        keys.map do |key|
          Date.parse(key).strftime("%d/%m/%Y\n%A")
        rescue Date::Error
          key
        end
      end

      def date_range
        @start_at..(@start_at + @duration)
      end
    end
  end
end
