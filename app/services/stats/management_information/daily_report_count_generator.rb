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
            csv << [rec[:name], rec[:saturday], rec[:sunday], rec[:monday],
                    rec[:tuesday], rec[:wednesday], rec[:thursday], rec[:friday]]
          end
        end
      end

      def headers
        week_range.map { |d| d.strftime("%d/%m/%Y\n%A") }.prepend('Name')
      end

      def aggregations
        @aggregations ||= DailyReportCountQuery.call(scheme: @scheme, date_range: week_range)
      end

      def week_range
        @day.beginning_of_week(:saturday)..@day.end_of_week(:saturday)
      end
    end
  end
end
