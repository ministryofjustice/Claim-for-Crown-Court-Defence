# frozen_string_literal: true

require 'csv'

module Stats
  module ManagementInformation
    class DailyReportGenerator
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
        log_error(e)
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

      #
      # - :id
      # - :scheme
      # - :case_number
      # - :supplier_number
      # - :organisation
      # - :case_type_name
      # - :bill_type
      # - :claim_total
      # - :submission_type
      # - :transitioned_at
      # - :last_submitted_at
      # - :originally_submitted_at
      # - :allocated_at
      # - :completed_at
      # - :current_or_end_state
      # - :state_reason_code
      # - :rejection_reason
      # - :case_worker
      # - :disk_evidence_case
      # - :main_defendant
      # - :maat_reference
      # - :rep_order_issued_date
      # - :af1_lf1_processed_by
      # - :misc_fees

      # TODO: complete all required columns (without any N+1 queries)
      def row(rec)
        presenter = Presenter.new(rec)
        todos = %i[main_defendant maat_reference rep_order_issued_date af1_lf1_processed_by misc_fees]

        Settings
          .claim_csv_headers
          .reject { |header| todos.include?(header) }
          .map { |header| presenter.send(header) }
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
