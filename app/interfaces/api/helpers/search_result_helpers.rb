module API
  module Helpers
    module SearchResultHelpers
      private

      def fees
        object.fees&.split(',')&.map { |fee| fee.split('~') }
      end

      def claim_has_graduated_fees?
        graduated_fee_codes.present? && object.fee_type_code&.in?(graduated_fee_codes).eql?(true)
      end

      def graduated_fee_codes
        object.graduated_fee_types&.split(',')
      end

      def fee_is_interim_type?
        fees&.map do |fee|
          [
            fee[2].eql?('Fee::InterimFeeType'),
            fee[1].downcase.in?(['effective pcmh', 'trial start', 'retrial new solicitor', 'retrial start'])
          ].all?
        end&.any?
      end

      def contains_risk_based_fee
        contains_risk_based_final_fee? || (contains_risk_based_transfer_fee? && up_to_and_inc_pcmh_transfer?)
      end

      def contains_risk_based_final_fee?
        fees&.map do |fee|
          [
            fee[0].to_i.between?(0, 49),
            fee[1].in?(['Discontinuance', 'Guilty plea']),
            fee[2].eql?('Fee::GraduatedFeeType')
          ].all?
        end&.any?
      end

      def contains_risk_based_transfer_fee?
        fees&.map do |fee|
          [
            fee[0].to_i.between?(0, 49),
            fee[2].eql?('Fee::TransferFeeType')
          ].all?
        end&.any?
      end

      def contains_fee_of_type?(fee_type_description)
        fees&.map do |fee|
          [
            fee[2].eql?('Fee::InterimFeeType'),
            fee[1].eql?(fee_type_description)
          ].all?
        end&.any?
      end

      def contains_conference_and_view?
        fees&.map do |fee|
          [
            fee[2].eql?('Fee::BasicFeeType'),
            fee[1].eql?('Conferences and views'),
            fee[0].to_i.positive?
          ].all?
        end&.any?
      end

      def risk_based_class_letter?
        object.class_letter&.in?(%w[E F G H I])
      end

      def interim_claim?
        object.scheme_type.eql?('Interim')
      end

      def hardship_claim?
        object.scheme_type.match?(/hardship/i)
      end

      def is_submitted?
        object.state.eql?('submitted')
      end

      def allocation_type_is_grad?
        object.allocation_type.eql?('Grad')
      end

      def allocation_type_is_fixed?
        object.allocation_type.eql?('Fixed')
      end

      def up_to_and_inc_pcmh_transfer?
        object.transfer_stage_id.eql?(10)
      end

      def last_injection_attempt_succeeded
        object&.last_injection_succeeded || false
      end

      def contains_clar_fees?
        fees&.map do |fee|
          [
            fee[2].eql?('Fee::MiscFeeType'),
            fee[1].in?(['Paper heavy case', 'Unused materials (up to 3 hours)', 'Unused materials (over 3 hours)']),
            fee[0].to_i.positive?
          ].all?
        end&.any?
      end

      def contains_additional_prep_fee?
        fees&.map do |fee|
          [
            fee[2].eql?('Fee::MiscFeeType'),
            fee[1].eql?('Additional preparation fee'),
            fee[0].to_i.positive?
          ].all?
        end&.any?
      end
    end
  end
end
