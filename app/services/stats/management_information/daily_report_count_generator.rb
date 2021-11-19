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
        @scheme = kwargs[:scheme]&.to_s&.upcase
        @day = kwargs[:day]
        @duration = kwargs[:duration] || 1.month

        raise ArgumentError, 'scheme must be "agfs" or "lgfs"' if %w[AGFS LGFS].exclude?(@scheme)
        raise ArgumentError, 'day must be provided' if @day.blank?
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
            csv << row_for(rec)
          end
        end
      end

      def aggregations
        @aggregations ||= DailyReportCountQuery.call(scheme: @scheme, date_range: date_range)
      end

      def headers_for(rec)
        keys = rec.keys.map { |k| k.to_s.humanize }

        keys.map do |key|
          Date.parse(key).strftime("%d/%m/%Y\n%A")
        rescue Date::Error
          key
        end
      end

      def row_for(rec)
        date_range.map(&:iso8601).map { |date| rec[date] }.prepend(rec[:name])
      end

      # TODO: make interval an arg with default of 1.month
      def date_range
        @day..(@day + @duration)
      end
    end
  end
end
