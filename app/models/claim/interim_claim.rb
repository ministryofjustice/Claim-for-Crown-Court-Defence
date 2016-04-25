# == Schema Information
#
# Table name: claims
#
#  id                       :integer          not null, primary key
#  additional_information   :text
#  apply_vat                :boolean
#  state                    :string
#  last_submitted_at        :datetime
#  case_number              :string
#  advocate_category        :string
#  first_day_of_trial       :date
#  estimated_trial_length   :integer          default(0)
#  actual_trial_length      :integer          default(0)
#  fees_total               :decimal(, )      default(0.0)
#  expenses_total           :decimal(, )      default(0.0)
#  total                    :decimal(, )      default(0.0)
#  external_user_id         :integer
#  court_id                 :integer
#  offence_id               :integer
#  created_at               :datetime
#  updated_at               :datetime
#  valid_until              :datetime
#  cms_number               :string
#  authorised_at            :datetime
#  creator_id               :integer
#  evidence_notes           :text
#  evidence_checklist_ids   :string
#  trial_concluded_at       :date
#  trial_fixed_notice_at    :date
#  trial_fixed_at           :date
#  trial_cracked_at         :date
#  trial_cracked_at_third   :string
#  source                   :string
#  vat_amount               :decimal(, )      default(0.0)
#  uuid                     :uuid
#  case_type_id             :integer
#  form_id                  :string
#  original_submission_date :datetime
#  retrial_started_at       :date
#  retrial_estimated_length :integer          default(0)
#  retrial_actual_length    :integer          default(0)
#  retrial_concluded_at     :date
#  type                     :string
#  disbursements_total      :decimal(, )      default(0.0)
#  case_concluded_at        :date
#  transfer_court_id        :integer
#  supplier_number          :string
#  effective_pcmh_date      :date
#  legal_aid_transfer_date  :date
#  allocation_type          :string
#

module Claim
  class InterimClaim < BaseClaim

    validates_with ::Claim::InterimClaimValidator
    validates_with ::Claim::InterimClaimSubModelValidator

    belongs_to :transfer_court, foreign_key: 'transfer_court_id', class_name: 'Court'

    has_one :interim_fee, foreign_key: :claim_id, class_name: 'Fee::InterimFee', dependent: :destroy, inverse_of: :claim
    has_one :warrant_fee, foreign_key: :claim_id, class_name: 'Fee::WarrantFee', dependent: :destroy, inverse_of: :claim

    accepts_nested_attributes_for :interim_fee, reject_if: :all_blank, allow_destroy: false
    accepts_nested_attributes_for :warrant_fee, reject_if: :all_blank, allow_destroy: false

    def eligible_case_types
      CaseType.interims
    end

    def eligible_interim_fee_types
      Fee::InterimFeeType.top_levels
    end

    def external_user_type
      :litigator
    end

    def interim?
      true
    end

    private

    def provider_delegator
      provider
    end

    def destroy_all_invalid_fee_types
      unless interim_fee.try(:is_interim_warrant?)
        warrant_fee.try(:delete)
      end
    end
  end
end
