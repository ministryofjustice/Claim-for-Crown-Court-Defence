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
#  value_band_id            :integer
#  retrial_reduction        :boolean          default(FALSE)
#

module Claim
  class LitigatorClaim < BaseClaim
    route_key_name 'litigators_claim'

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

    before_validation do
      assign_total_attrs
    end

    SUBMISSION_STAGES = [
      {
        name: :case_details,
        transitions: [
          { to_stage: :defendants }
        ]
      },
      {
        name: :defendants,
        transitions: [
          {
            to_stage: :offence_details,
            condition: ->(claim) { !claim.fixed_fee_case? }
          },
          {
            to_stage: :fixed_fees,
            condition: ->(claim) { claim.fixed_fee_case? }
          }
        ],
        dependencies: %i[case_details]
      },
      {
        name: :offence_details,
        transitions: [
          { to_stage: :graduated_fees }
        ],
        dependencies: %i[case_details defendants]
      },
      {
        name: :fixed_fees,
        transitions: [
          { to_stage: :miscellaneous_fees }
        ],
        dependencies: %i[case_details defendants]
      },
      {
        name: :graduated_fees,
        transitions: [
          { to_stage: :miscellaneous_fees }
        ],
        dependencies: %i[case_details defendants offence_details]
      },
      {
        name: :miscellaneous_fees,
        transitions: [
          { to_stage: :disbursements }
        ]
      },
      {
        name: :disbursements,
        transitions: [
          { to_stage: :travel_expenses }
        ]
      },
      {
        name: :travel_expenses,
        transitions: [
          { to_stage: :supporting_evidence }
        ]
      },
      { name: :supporting_evidence }
    ].freeze

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

    def assign_total_attrs
      # TODO: understand if this check is really needed
      # left it here mostly to ensure the new changes do
      # not impact anything API related
      return if from_api?
      if case_type&.is_fixed_fee?
        assign_fixed_total_attrs
      else
        assign_graduated_total_attrs
      end
      assign_expenses_total if expenses_changed?
      return unless total_changes_required?
      assign_total
      assign_vat
    end

    def assign_fixed_total_attrs
      assign_fees_total(%i[fixed_fee misc_fees]) if fees_changed?
    end

    def assign_graduated_total_attrs
      assign_fees_total(%i[graduated_fee misc_fees]) if fees_changed?
    end

    def fees_changed?
      if case_type&.is_fixed_fee?
        fixed_fee_changed? || misc_fees_changed?
      else
        graduated_fee_changed? || misc_fees_changed?
      end
    end

    def total_changes_required?
      fees_changed? || expenses_changed?
    end

    def fixed_fee_changed?
      fixed_fee&.changed?
    end

    def graduated_fee_changed?
      graduated_fee&.changed?
    end
  end
end
