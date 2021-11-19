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
          csv << headers
          aggregations.each do |rec|
            csv << row_for(rec)
          end
        end
      end

      # TODO: remove coupling by using the keys returned from query instead
      def headers
        date_range.map { |d| d.strftime("%d/%m/%Y\n%A") }.prepend('Name')
      end

      def aggregations
        @aggregations ||= DailyReportCountQuery.call(scheme: @scheme, date_range: date_range)
      end

      def row_for(rec)
        date_range.map(&:iso8601).map { |date| rec[date] }.prepend(rec[:name])
      end

      # TODO: make interval an arg with default of 1.month
      def date_range
        @day..(@day + 1.month)
      end
    end
  end
end
