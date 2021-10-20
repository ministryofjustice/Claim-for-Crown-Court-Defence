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

      # OPTIMIZE: could instantiate a "record/claim_journey" struct from record hash for clearer calls?!
      def initialize(record)
        @record = record
      end

      attr_reader :record

      def submission_type
        journey.first[:to] == 'submitted' ? 'new' : journey.first[:to]
      end

      def transitioned_at
        submissions.present? ? submissions.first[:created_at].strftime('%d/%m/%Y') : 'n/a'
      end

      def last_submitted_at
        record[:last_submitted_at]&.strftime('%d/%m/%Y')
      end

      def originally_submitted_at
        record[:original_submission_date]&.strftime('%d/%m/%Y')
      end

      # why `.last`, there should be only one allocation per journey?! see optimize below
      def allocated_at
        allocations.present? ? allocations.last[:created_at].strftime('%d/%m/%Y') : 'n/a'
      end

      # why `.first`, there should be only one completion per journey?! see optimize below
      def completed_at
        completions.present? ? completions.first[:created_at].strftime('%d/%m/%Y %H:%M') : 'n/a'
      end

      # This is the current claim journey end state, not that of the claim!
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

      def method_missing(method_name, *args, &block)
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

      # OPTIMIZE: there should be only one submission per journey as each journey
      # slice starts with a submission state (or possibly not if the submission was
      # over 6 months ago). So could use `.find` to return first found and change name and
      # callers to rely on it.
      def submissions
        @submissions ||= journey.select { |transition| SUBMITTED_STATES.include?(transition[:to]) }
      end

      # OPTIMIZE: there should be only one allocation per journey as deallocated
      # allocations (and deallocations themselves) are removed. So could use `.find`
      # to return first found and change name and callers to rely on it.
      def allocations
        @allocations ||= journey.select { |transition| transition[:to] == 'allocated' }
      end

      # OPTIMIZE: there should be only one completion per journey as a journey
      # is defined as a slice ending in a completion (or remainder, when it is the last
      # journey). So could use `.find` to return first found and change name and
      # callers to rely on it.
      def completions
        @completions ||= journey.select { |transition| COMPLETED_STATES.include?(transition[:to]) }
      end

      def journey
        @journey ||= record[:journey]
      end
    end
  end
end
