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
#  transfer_case_number     :string
#  clone_source_id          :integer
#  last_edited_at           :datetime
#  deleted_at               :datetime
#  providers_ref            :string
#  disk_evidence            :boolean          default(FALSE)
#  fees_vat                 :decimal(, )      default(0.0)
#  expenses_vat             :decimal(, )      default(0.0)
#  disbursements_vat        :decimal(, )      default(0.0)
#

module Claim
  class LitigatorClaim < BaseClaim
    set_singular_route_key 'litigators_claim'

    validates_with ::Claim::LitigatorClaimValidator, unless: proc { |c| c.disable_for_state_transition.eql?(:all) }
    validates_with ::Claim::LitigatorSupplierNumberValidator, on: :create
    validates_with ::Claim::LitigatorClaimSubModelValidator

    has_one :fixed_fee, foreign_key: :claim_id, class_name: 'Fee::FixedFee', dependent: :destroy, inverse_of: :claim
    has_one :warrant_fee, foreign_key: :claim_id, class_name: 'Fee::WarrantFee', dependent: :destroy, inverse_of: :claim
    has_one :graduated_fee,
            foreign_key: :claim_id,
            class_name: 'Fee::GraduatedFee',
            dependent: :destroy,
            inverse_of: :claim

    accepts_nested_attributes_for :fixed_fee, reject_if: :all_blank, allow_destroy: false
    accepts_nested_attributes_for :warrant_fee, reject_if: :all_blank, allow_destroy: false
    accepts_nested_attributes_for :graduated_fee, reject_if: :all_blank, allow_destroy: false

    def lgfs?
      self.class.lgfs?
    end

    def final?
      true
    end

    # Fixed Fee Adder requires a fixed_fees method
    def fixed_fees
      fixed_fee.nil? ? [] : [fixed_fee]
    end

    def eligible_case_types
      CaseType.lgfs
    end

    def eligible_basic_fee_types
      Fee::BasicFeeType.lgfs
    end

    def eligible_misc_fee_types
      Fee::MiscFeeType.lgfs
    end

    def eligible_fixed_fee_types
      Fee::FixedFeeType.top_levels.lgfs
    end

    def external_user_type
      :litigator
    end

    def requires_case_concluded_date?
      true
    end

    private

    def provider_delegator
      provider
    end

    def destroy_all_invalid_fee_types
      return unless case_type.present?

      if case_type.is_fixed_fee?
        graduated_fee.try(:destroy)
        self.graduated_fee = nil
      else
        fixed_fee.try(:destroy)
        self.fixed_fee = nil
      end
    end
  end
end
