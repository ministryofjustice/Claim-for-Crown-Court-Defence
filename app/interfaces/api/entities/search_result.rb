module API
  module Entities
    class SearchResult < BaseEntity

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

      def id
        object['id']
      end

      def uuid
        object['uuid']
      end

      def scheme
        object['scheme']
      end

      def scheme_type
        object['scheme_type']
      end

      def state
        object['state']
      end

      def court_name
        object['court_name']
      end

      def case_type
        object['case_type']
      end

      def total
        object['total']
      end

      def external_user
        object['external_user']
      end

      def last_submitted_at
        object['last_submitted_at']
      end

      def defendants
        object['defendants']
      end

      def maat_references
        object['maat_references']
      end

      def state_display
        state.humanize
      end

      def total_display
        ActiveSupport::NumberHelper.number_to_currency(total, precision: 2, delimiter: ',')
      end

      def disk_evidence
        object['disk_evidence'].eql?(true)
      end

      def last_submitted_at_display
        last_submitted_at.strftime('%d/%m/%Y')
      end

      def redetermination
        state.eql?('redetermination')
      end

      def fees
        object['fees']&.split(',')&.map { |fee| fee.split('~') }
      end

      def awaiting_written_reasons
        state.eql?('awaiting_written_reasons')
      end

      def cracked
        case_type.eql?('Cracked Trial')
      end

      def trial
        case_type.eql?('Trial')
      end

      def guilty_plea
        case_type.eql?('Guilty plea')
      end

      def fixed_fee
        object['is_fixed_fee'].eql?(true)
      end

      def graduated_fees
        object['fee_type_code']&.in?(graduated_fee_codes).eql?(true)
      end

      def graduated_fee_codes
        object['graduated_fee_types']&.split(',')
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
        (risk_based_class_letter && contains_risk_based_fee).eql?(true)
      end

      def fee_is_interim_type
        fees.map do |fee|
          [
              fee[2].eql?('Fee::InterimFeeType'),
              fee[1].downcase.in?(['effective pcmh', 'trial start', 'retrial new solicitor', 'retrial start'])
          ].all?
        end.any?
      end

      def risk_based_class_letter
        object['class_letter']&.in?(%w(E F H I))
      end

      def contains_risk_based_fee
        fees&.map do |fee|
          [
              fee[0].to_i.between?(1, 50),
              fee[1].eql?('Guilty plea'),
              fee[2].eql?('Fee::GraduatedFeeType')
          ]&.all?
        end&.any?
      end

      def interim_claim?
        scheme_type.eql?('Interim')
      end

      def contains_fee_of_type(fee_type_description)
        fees.map do |fee|
          [
              fee[2].eql?('Fee::InterimFeeType'),
              fee[1].eql?(fee_type_description)
          ].all?
        end.any?
      end
    end
  end
end
