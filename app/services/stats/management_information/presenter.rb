# frozen_string_literal: true

module Stats
  module ManagementInformation
    class Presenter
      SUBMITTED_STATES = %w[submitted redetermination awaiting_written_reasons].freeze

      attr_reader :record

      def initialize(record)
        @record = record
      end

      delegate_missing_to :record

      def submission_type
        journey.first[:to] == 'submitted' ? 'new' : journey.first[:to]
      end

      def transitioned_at
        submissions.present? ? submissions.first[:created_at].strftime('%d/%m/%Y') : 'n/a'
      end

      private

      def submissions
        journey.select { |transition| SUBMITTED_STATES.include?(transition[:to]) }
      end

      def journey
        @journey ||= record[:journey]
      end
    end
  end
end
