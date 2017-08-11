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
      expose :external_user
      expose :last_submitted_at
      expose :last_submitted_at_display
      expose :defendants
      expose :maat_references
      expose :filter do
        expose :disk_evidence
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

      def state_display
        object.state.humanize
      end

      def total_display
        ActiveSupport::NumberHelper.number_to_currency(object.total, precision: 2, delimiter: ',')
      end

      def last_submitted_at
        object.last_submitted_at.to_datetime.to_i
      end

      def last_submitted_at_display
        object.last_submitted_at.strftime('%d/%m/%Y')
      end

      def disk_evidence
        object.disk_evidence.eql?('t')
      end

      def redetermination
        object.state.eql?('redetermination')
      end

      def fixed_fee
        object.is_fixed_fee.eql?('t') && is_submitted?
      end

      def awaiting_written_reasons
        object.state.eql?('awaiting_written_reasons')
      end

      def cracked
        ['Cracked before retrial', 'Cracked Trial'].include?(object.case_type) && is_submitted?
      end

      def trial
        %w[Trial Retrial].include?(object.case_type) && is_submitted?
      end

      def guilty_plea
        ['Discontinuance', 'Guilty plea'].include?(object.case_type) && is_submitted?
      end

      def graduated_fees
        (object.fee_type_code&.in?(graduated_fee_codes).eql?(true) || allocation_type_is_grad?) && is_submitted?
      end

      def interim_fees
        interim_claim? && fee_is_interim_type && is_submitted?
      end

      def warrants
        interim_claim? && contains_fee_of_type('Warrant')
      end

      def interim_disbursements
        interim_claim? && contains_fee_of_type('Disbursement only')
      end

      def risk_based_bills
        (risk_based_class_letter && contains_risk_based_fee).eql?(true) && is_submitted?
      end
    end
  end
end
