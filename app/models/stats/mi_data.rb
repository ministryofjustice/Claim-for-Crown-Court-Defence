module Stats
  class MIData < ApplicationRecord
    self.table_name = 'mi_data'

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
      assessment_vat: { object: :assessment, att: :vat_amount },
      scheme_name: { object: :fee_scheme, att: :name },
      scheme_number: { object: :fee_scheme, att: :version }
    }.freeze

    CALCULATIONS = {
      amount_claimed: %i[total vat_amount],
      amount_authorised: %i[assessment_total assessment_vat]
    }.freeze

    CLAIM_TYPE_CONVERSIONS = {
      'Claim::AdvocateInterimClaim' =>  'Advocate interim claim',
      'Claim::AdvocateClaim'        =>  'Advocate final claim',
      'Claim::InterimClaim'         =>  'Litigator interim claim',
      'Claim::LitigatorClaim'       =>  'Litigator final claim',
      'Claim::TransferClaim'        =>  'Litigator transfer claim'
    }.freeze

    class << self
      def import(claim)
        new_mi = Stats::MIData.new
        DUPLICATE.each { |att| new_mi.send("#{att}=", claim.send(att)) }
        COUNT.each { |att, source| new_mi.send("#{att}=", claim.send(source[:object]).where(source[:where]).count) }
        OBJECT_VALUE.each { |att, source| new_mi.send("#{att}=", claim.send(source[:object])&.send(source[:att])) }
        CALCULATIONS.each { |att, sum| new_mi.send("#{att}=", new_mi.send(sum[0]) + new_mi.send(sum[1])) }
        new_mi.ppe = claim.fees.find_by(fee_type_id: 11)&.quantity.to_i
        new_mi.claim_type = CLAIM_TYPE_CONVERSIONS[claim.type.to_s]
        new_mi.offence_type = claim.offence&.offence_band&.description || claim.offence&.offence_class&.class_letter
        new_mi.save
      end
    end
  end
end
