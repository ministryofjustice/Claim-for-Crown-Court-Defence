# frozen_string_literal: true

module Stats
  module ManagementInformation
    class Presenter
      # OPTIMIZE: share this array more centrally?!
      # see also Claims::StateMachine::CASEWORKER_DASHBOARD_UNALLOCATED_STATES
      SUBMITTED_STATES = %w[submitted redetermination awaiting_written_reasons].freeze

      # OPTIMIZE: share this array with the SQL query itself?!
      # see also Claims::StateMachine::CASEWORKER_DASHBOARD_COMPLETED_STATES
      COMPLETED_STATES = %w[rejected refused authorised part_authorised].freeze

      def initialize(record)
        @record = record
      end

      attr_reader :record

      def submission_type
        journey.first[:to] == 'submitted' ? 'new' : journey.first[:to]
      end

      def claim_total
        format('%.2f', record[:claim_total])
      end

      def transitioned_at
        submission.present? ? submission[:created_at].strftime('%d/%m/%Y') : 'n/a'
      end

      def last_submitted_at
        record[:last_submitted_at]&.strftime('%d/%m/%Y')
      end

      def originally_submitted_at
        record[:originally_submitted_at]&.strftime('%d/%m/%Y')
      end

      def allocated_at
        allocation.present? ? allocation[:created_at].strftime('%d/%m/%Y') : 'n/a'
      end

      def completed_at
        record[:completed_at]&.strftime('%d/%m/%Y %H:%M') || 'n/a'
      end

      def current_or_end_state
        state = journey.last[:to]
        SUBMITTED_STATES.include?(state) ? 'submitted' : state
      end

      def state_reason_code
        reason_codes = journey.last[:reason_code]
        YAML.safe_load(reason_codes).join(', ') if reason_codes
      end

      def rejection_reason
        journey.last[:reason_text]
      end

      def case_worker
        if journey.last[:to].eql?('allocated')
          journey.last[:subject_name]
        elsif COMPLETED_STATES.include?(journey.last[:to])
          journey.last[:author_name]
        else
          'n/a'
        end
      end

      def disk_evidence_case
        record[:disk_evidence] ? 'Yes' : 'No'
      end

      def rep_order_issued_date
        record[:rep_order_issued_date]&.strftime('%d/%m/%Y')
      end

      def main_hearing_date
        record[:main_hearing_date]&.strftime('%d/%m/%Y')
      end

      def method_missing(method_name, *args, &)
        if record.key?(method_name)
          record[method_name]
        else
          super
        end
      end

      def respond_to_missing?(method_name, *args)
        record.key?(method_name) || super
      end

      private

      def submission
        @submission ||= journey.find { |transition| SUBMITTED_STATES.include?(transition[:to]) }
      end

      # we have to find the last due to edge case of "stuck" claims that have been "unstuck".
      # such claims may have been [allocated, submitted, allocated, ...] so we want the last.
      def allocation
        @allocation ||= journey.reverse.find { |transition| transition[:to] == 'allocated' }
      end

      def journey
        @journey ||= record[:journey]
      end
    end
  end
end
