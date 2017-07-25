module API
  module Entities
    class SearchResult < BaseEntity
      include SearchResultHelpers

      expose :id
      expose :uuid
      expose :scheme
      expose :scheme_type
      expose :case_number
      expose :state
      expose :state_display
      expose :court_name
      expose :case_type
      expose :total, format_with: :decimal
      expose :total_display
      expose :opened_for_redetermination?, as: :redetermination
      expose :disk_evidence
      expose :external_user
      expose :last_submitted_at
      expose :last_submitted_at_display
      expose :defendants
      expose :maat_references
      expose :filter do
        expose :redetermination
        expose :fixed_fee
        expose :awaiting_written_reasons
        expose :cracked
        expose :trial
        expose :guilty_plea
        expose :graduated_fees
        expose :interim_fees
        expose :warrants
        expose :interim_disbursements
        expose :risk_based_bills
      end

      private

      def scheme
        object.type.gsub(/Claim|::/, '')
      end

      def scheme_type
        scheme.eql?('Litigator') ? 'Final' : scheme
      end

      def state_display
        object.state.humanize
      end

      def court_name
        object.court&.name
      end

      def case_type
        object.case_type&.name
      end

      def total_display
        ActiveSupport::NumberHelper.number_to_currency(object.total, precision: 2, delimiter: ',')
      end

      def disk_evidence
        object.disk_evidence.present? && object.disk_evidence
      end

      def external_user
        "#{object&.external_user.first_name} #{object&.external_user.last_name}"
      end

      def last_submitted_at
        object.last_submitted_at.to_i
      end

      def last_submitted_at_display
        object.last_submitted_at.strftime('%d/%m/%Y')
      end

      def defendants
        object&.defendants.map { |defendant| [defendant.first_name, defendant.last_name].join(' ') }.join(', ')
      end

      def maat_references
        object&.representation_orders.map(&:maat_reference).join(', ')
      end

      def redetermination
        object.redetermination?
      end

      def fixed_fee
        object&.case_type&.is_fixed_fee
      end

      def awaiting_written_reasons
        object.awaiting_written_reasons?
      end

      def cracked
        object&.case_type&.name.eql?('Cracked Trial')
      end

      def trial
        object&.case_type&.name.eql?('Trial')
      end

      def guilty_plea
        object&.case_type&.name.eql?('Guilty plea')
      end

      def graduated_fees
        object.allocation_type.eql?('Grad') ||
          object.case_type.fee_type_code.in?(::Fee::GraduatedFeeType.pluck(:unique_code))
      end

      def interim_fees
        interim_claim? && fee_is_interim_type
      end

      def warrants
        interim_claim? && contains_fee_of_type('Warrant')
      end

      def interim_disbursements
        interim_claim? && contains_fee_of_type('Disbursement only')
      end

      def risk_based_bills
        risk_based_class_letter && contains_risk_based_fee
      end
    end
  end
end
