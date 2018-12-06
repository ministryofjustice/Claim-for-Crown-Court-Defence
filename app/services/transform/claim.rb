module Transform
  class Claim
    DUPLICATE = %w[disk_evidence retrial_reduction case_concluded_at effective_pcmh_date first_day_of_trial
                   legal_aid_transfer_date retrial_concluded_at retrial_started_at trial_concluded_at
                   trial_cracked_at trial_fixed_at trial_fixed_notice_at authorised_at created_at
                   last_submitted_at original_submission_date disbursements_total disbursements_vat
                   expenses_total expenses_vat fees_total fees_vat total vat_amount actual_trial_length
                   estimated_trial_length retrial_actual_length retrial_estimated_length advocate_category
                   trial_cracked_at_third source supplier_number].freeze

    COUNT = {
      num_of_documents: { object: :documents, where: '' },
      num_of_defendants: { object: :defendants, where: '' },
      rejections: { object: :claim_state_transitions, where: "\"to\"='rejected'" },
      refusals: { object: :claim_state_transitions, where: "\"to\"='refused'" }
    }.freeze

    OBJECT_VALUE = {
      court: { object: :court, att: :name },
      transfer_court: { object: :transfer_court, att: :name },
      case_type: { object: :case_type, att: :name },
      offence_name: { object: :offence, att: :description },
      date_last_assessed: { object: :assessment, att: :created_at },
      provider_name: { object: :provider, att: :name },
      provider_type: { object: :provider, att: :provider_type },
      assessment_total: { object: :assessment, att: :total },
      assessment_fees: { object: :assessment, att: :fees },
      assessment_expenses: { object: :assessment, att: :expenses },
      assessment_disbursements: { object: :assessment, att: :disbursements },
      assessment_vat: { object: :assessment, att: :vat_amount },
      scheme_name: { object: :fee_scheme, att: :name },
      scheme_number: { object: :fee_scheme, att: :version }
    }.freeze

    CALCULATIONS = {
      amount_claimed: %i[total vat_amount],
      amount_authorised: %i[assessment_total assessment_vat]
    }.freeze

    CLAIM_TYPE_CONVERSIONS = {
      'Claim::AdvocateInterimClaim' => 'Advocate interim claim',
      'Claim::AdvocateClaim' => 'Advocate final claim',
      'Claim::InterimClaim' => 'Litigator interim claim',
      'Claim::LitigatorClaim' => 'Litigator final claim',
      'Claim::TransferClaim' => 'Litigator transfer claim'
    }.freeze

    class << self
      def call(claim)
        hash = {}
        @claim = claim
        DUPLICATE.each { |att| hash[att.to_sym] = claim.send(att) }
        COUNT.each { |att, source| hash[att] = claim.send(source[:object]).where(source[:where]).count }
        OBJECT_VALUE.each { |att, source| hash[att] = claim.send(source[:object])&.send(source[:att]) }
        CALCULATIONS.each { |att, sum| hash[att] = (hash[sum[0]] || 0) + (hash[sum[1]] || 0) }
        hash[:ppe] = ppe
        hash[:claim_type] = CLAIM_TYPE_CONVERSIONS[claim.type.to_s]
        hash[:offence_type] = claim.offence&.offence_band&.description || claim.offence&.offence_class&.class_letter
        hash
      end

      private

      attr_accessor :claim

      def ppe
        if @claim.agfs?
          @claim.fees.find_by(fee_type_id: ::Fee::BaseFeeType.find_by_id_or_unique_code('BAPPE'))&.quantity.to_i
        else
          @claim.fees.where(type: %w[Fee::GraduatedFee Fee::TransferFee Fee::InterimFee]).first&.quantity.to_i
        end
      end
    end
  end
end
