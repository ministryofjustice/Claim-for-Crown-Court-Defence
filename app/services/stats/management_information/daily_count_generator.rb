# frozen_string_literal: true

require 'csv'

module Stats
  module ManagementInformation
    class DailyCountGenerator
      def self.call(options = {})
        new(options).call
      end

      def initialize(options = {})
        @scheme = options[:scheme]
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
          csv << %w[Name Saturday Sunday Monday Tuesday Wednesday Thursday Friday]
          aggregations.each do |rec|
            csv << [rec[:name], rec[:saturday], rec[:sunday], rec[:monday],
                    rec[:tuesday], rec[:wednesday], rec[:thursday], rec[:friday]]
          end
        end
      end

      def aggregations
        @aggregations ||= DailyCountQuery.call(scheme: @scheme, day: Date.parse('2021-06-30'))
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
