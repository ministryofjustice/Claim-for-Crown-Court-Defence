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
  class AdvocateClaim < BaseClaim

    has_many :fixed_fees, foreign_key: :claim_id, class_name: 'Fee::FixedFee', dependent: :destroy, inverse_of: :claim
    accepts_nested_attributes_for :fixed_fees, reject_if: :all_blank, allow_destroy: true

    validates_with ::Claim::AdvocateClaimValidator
    validates_with ::Claim::AdvocateClaimSubModelValidator

    delegate :requires_cracked_dates?, to: :case_type

    def eligible_case_types
      CaseType.agfs
    end

    def eligible_basic_fee_types
      Fee::BasicFeeType.agfs
    end

    def eligible_misc_fee_types
      Fee::MiscFeeType.agfs
    end

    def eligible_fixed_fee_types
      Fee::FixedFeeType.top_levels.agfs
    end

    def external_user_type
      :advocate
    end

    def agfs?
      true
    end

    private

    def provider_delegator
      if provider.firm?
        provider
      elsif provider.chamber?
        external_user
      else
        raise "Unknown provider type: #{provider.provider_type}"
      end
    end

    def default_values
      self.supplier_number ||= (provider_delegator.supplier_number rescue nil)
      super
    end

    def destroy_all_invalid_fee_types
      if case_type.present? && case_type.is_fixed_fee?
        basic_fees.map(&:clear) unless basic_fees.empty?
      else
        fixed_fees.destroy_all unless fixed_fees.empty?
      end
    end
  end
end

