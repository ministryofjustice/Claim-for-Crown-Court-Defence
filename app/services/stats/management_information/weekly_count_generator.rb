# frozen_string_literal: true

require 'csv'

module Stats
  module ManagementInformation
    class WeeklyCountGenerator
      def self.call(options = {})
        new(options).call
      end

      def initialize(options = {})
        @scheme = options[:scheme]&.to_s&.upcase
        @day = options[:day]
        raise ArgumentError, 'scheme must be "agfs" or "lgfs"' if @scheme.present? && %w[AGFS LGFS].exclude?(@scheme)
        raise ArgumentError, 'day must be provided' if @day.blank?
      end

      def call
        output = generate_report
        Stats::Result.new(output, :csv)
      end

      private

      def generate_report
        log_info('Daily MI statistics generation started...')
        content = generate_csv
        log_info('Daily MI statistics generation finished')
        content
      rescue StandardError => e
        log_error(e)
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
        @aggregations ||= WeeklyCountQuery.call(scheme: @scheme, date_range: week_range)
      end

      def week_range
        @day.beginning_of_week(:saturday)..@day.end_of_week(:saturday)
      end

      def log_error(error)
        LogStuff.error(class: self.class.name,
                       action: caller_locations(1, 1)[0].label,
                       error_message: "#{error.class} - #{error.message}",
                       error_backtrace: error.backtrace.inspect.to_s) do
                         'MI Report generation error'
                       end
      end

      def log_info(message)
        LogStuff.info(class: self.class.name, action: caller_locations(1, 1)[0].label) { message }
      end
    end
  end
end
