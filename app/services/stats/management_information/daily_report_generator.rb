# frozen_string_literal: true

require 'csv'

module Stats
  module ManagementInformation
    class DailyReportGenerator
      include StuffLogger

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
        log_info('Daily MI Report generation started...')
        content = generate_csv
        log_info('Daily MI Report generation finished')
        content
      rescue StandardError => e
        log_error(e, 'Daily MI Report generation error')
        raise
      end

      def generate_csv
        CSV.generate do |csv|
          csv << headers
          claim_journeys.each do |rec|
            csv << row(rec)
          end
        end
      end

      def headers
        Settings.claim_csv_headers.map { |header| header.to_s.humanize }
      end

      def claim_journeys
        @claim_journeys ||= DailyReportQuery.call(scheme: @scheme)
      end

      def row(rec)
        presenter = Presenter.new(rec)

        Settings
          .claim_csv_headers
          .map { |header| presenter.send(header) }
      end
    end
  end
end
