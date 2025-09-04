module API
  module Entities
    class SearchResult < BaseEntity
      include Helpers::SearchResultHelpers

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
      expose :injection_errors

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
        expose :lgfs_warrants
        expose :agfs_warrants
        expose :interim_disbursements
        expose :risk_based_bills
        expose :injection_errored
        expose :cav_warning
        expose :supplementary
        expose :agfs_hardship
        expose :lgfs_hardship
        expose :clar_fees_warning
        expose :additional_prep_fee_warning
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

      # for display purposes we only want to use the injection error header
      def injection_errors
        I18n.t('shared.injection_errors.error') if injection_errors_present
      end

      def injection_errors_present
        JSON.parse(object.injection_errors)['errors'].present?
      rescue TypeError
        false
      end

      def disk_evidence
        object.disk_evidence.to_i
      end

      def redetermination
        (object.state.eql?('redetermination') && !hardship_claim?).to_i
      end

      def fixed_fee
        ((object.is_fixed_fee || allocation_type_is_fixed?) && is_submitted?).to_i
      end

      def awaiting_written_reasons
        object.state.eql?('awaiting_written_reasons').to_i
      end

      def cracked
        (['Cracked before retrial', 'Cracked Trial'].include?(object.case_type) && is_submitted?).to_i
      end

      def trial
        (%w[Trial Retrial].include?(object.case_type) && is_submitted?).to_i
      end

      def guilty_plea
        (['Discontinuance', 'Guilty plea'].include?(object.case_type) && is_submitted?).to_i
      end

      def graduated_fees
        ((claim_has_graduated_fees? || allocation_type_is_grad?) && is_submitted?).to_i
      end

      def interim_fees
        (interim_claim? && fee_is_interim_type? && is_submitted?).to_i
      end

      def lgfs_warrants
        (interim_claim? && contains_fee_of_type?('Warrant')).to_i
      end

      def agfs_warrants
        object.case_type.eql?('Warrant').to_i
      end

      def interim_disbursements
        (interim_claim? && contains_fee_of_type?('Disbursement only')).to_i
      end

      def risk_based_bills
        ((risk_based_class_letter? && contains_risk_based_fee?).eql?(true) && is_submitted?).to_i
      end

      def injection_errored
        injection_errors_present.to_i
      end

      def cav_warning
        (last_injection_attempt_succeeded? && contains_conference_and_view?).to_i
      end

      def clar_fees_warning
        (last_injection_attempt_succeeded? && contains_clar_fees?).to_i
      end

      def additional_prep_fee_warning
        (last_injection_attempt_succeeded? && contains_additional_prep_fee?).to_i
      end

      def supplementary
        object.case_type.eql?('Supplementary').to_i
      end

      def agfs_hardship
        object.scheme_type.eql?('AdvocateHardship').to_i
      end

      def lgfs_hardship
        object.scheme_type.eql?('LitigatorHardship').to_i
      end
    end
  end
end
