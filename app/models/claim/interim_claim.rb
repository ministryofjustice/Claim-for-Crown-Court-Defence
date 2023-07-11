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
  class InterimClaim < BaseClaim
    route_key_name 'litigators_interim_claim'

    validates_with ::Claim::InterimClaimValidator, unless: proc { |c| c.disable_for_state_transition.eql?(:all) }
    validates_with ::Claim::LitigatorSupplierNumberValidator, if: proc { |c| c.draft? }
    validates_with ::Claim::InterimClaimSubModelValidator

    has_one :interim_fee,
            foreign_key: :claim_id,
            class_name: 'Fee::InterimFee',
            dependent: :destroy,
            inverse_of: :claim,
            validate: proc { |claim| claim.step_validation_required?(:interim_fees) }

    accepts_nested_attributes_for :interim_fee, reject_if: :all_blank, allow_destroy: false

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
          { to_stage: :offence_details }
        ],
        dependencies: %i[case_details]
      },
      {
        name: :offence_details,
        transitions: [
          { to_stage: :interim_fees }
        ],
        dependencies: %i[case_details defendants]
      },
      {
        name: :interim_fees,
        transitions: [
          {
            to_stage: :travel_expenses,
            condition: ->(claim) { claim.interim_fee&.is_interim_warrant? }
          },
          {
            to_stage: :supporting_evidence,
            condition: ->(claim) { !claim.interim_fee&.is_interim_warrant? }
          }
        ],
        dependencies: %i[case_details defendants offence_details]
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

    def interim?
      true
    end

    def eligible_case_types
      CaseType.interims
    end

    def eligible_interim_fee_types
      Fee::InterimFeeType.by_case_type(case_type)
    end

    def external_user_type
      :litigator
    end

    private

    def provider_delegator
      provider
    end

    def cleaner
      Cleaners::InterimClaimCleaner.new(self)
    end

    def assign_total_attrs
      # TODO: understand if this check is really needed
      # left it here mostly to ensure the new changes do
      # not impact anything API related
      return if from_api?
      assign_fees_total(%i[interim_fee]) if interim_fee_changed?
      assign_expenses_total if expenses_changed?
      assign_disbursements_total if disbursements_changed?
      return unless total_changes_required?
      assign_total
      assign_vat
    end

    def total_changes_required?
      interim_fee_changed? || expenses_changed? || disbursements_changed?
    end

    def interim_fee_changed?
      interim_fee&.changed?
    end

    def disbursements_changed?
      disbursements.any?(&:changed?)
    end

    def fee_scheme_factory
      FeeSchemeFactory::LGFS
    end
  end
end
