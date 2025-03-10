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
  class TransferClaim < BaseClaim
    route_key_name 'litigators_transfer_claim'

    has_one :transfer_detail,
            foreign_key: :claim_id,
            class_name: 'Claim::TransferDetail',
            dependent: :destroy,
            inverse_of: :claim,
            validate: proc { |claim| claim.step_validation_required?(:transfer_fee_details) }
    has_one :transfer_fee,
            foreign_key: :claim_id,
            class_name: 'Fee::TransferFee',
            dependent: :destroy,
            inverse_of: :claim,
            validate: proc { |claim| claim.step_validation_required?(:transfer_fees) }

    delegate :lgfs?, to: :class

    accepts_nested_attributes_for :transfer_detail, reject_if: :all_blank, allow_destroy: false
    accepts_nested_attributes_for :transfer_fee, reject_if: :all_blank, allow_destroy: false

    validates_with ::Claim::TransferClaimValidator, unless: proc { |c| c.disable_for_state_transition.eql?(:all) }
    validates_with ::Claim::TransferClaimSubModelValidator

    before_validation do
      assign_total_attrs
    end

    # The ActiveSupport delegate method doesn't work with new objects - i.e.
    #   You can't say Claim.new(xxx: value) where xxx is delegated
    # So we have to do this instead.  Probably good to put it in a gem eventually.
    #
    DELEGATED_ATTRS = %i[litigator_type elected_case transfer_stage_id transfer_date transfer_date_dd
                         transfer_date_mm transfer_date_yyyy case_conclusion_id].freeze

    DELEGATED_ATTRS.each do |getter_method|
      define_method getter_method do
        proxy_transfer_detail.__send__(getter_method)
      end

      setter_method = :"#{getter_method}="
      define_method setter_method do |value|
        proxy_transfer_detail.__send__(setter_method, value)
      end
    end

    SUBMISSION_STAGES = [
      {
        name: :transfer_fee_details,
        transitions: [
          { to_stage: :case_details }
        ]
      },
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
        dependencies: %i[transfer_fee_details case_details]
      },
      {
        name: :offence_details,
        transitions: [
          { to_stage: :transfer_fees }
        ],
        dependencies: %i[transfer_fee_details case_details defendants]
      },
      {
        name: :transfer_fees,
        transitions: [
          { to_stage: :miscellaneous_fees }
        ],
        dependencies: %i[transfer_fee_details case_details defendants]
      },
      {
        name: :miscellaneous_fees,
        transitions: [
          { to_stage: :disbursements }
        ],
        dependencies: %i[transfer_fee_details]
      },
      {
        name: :disbursements,
        transitions: [
          { to_stage: :travel_expenses }
        ],
        dependencies: %i[transfer_fee_details]
      },
      {
        name: :travel_expenses,
        transitions: [
          { to_stage: :supporting_evidence }
        ],
        dependencies: %i[transfer_fee_details]
      },
      {
        name: :supporting_evidence,
        dependencies: %i[transfer_fee_details]
      }
    ].freeze

    def transfer?
      true
    end

    def requires_trial_dates?
      false
    end

    def requires_retrial_dates?
      false
    end

    def proxy_transfer_detail
      self.transfer_detail ||= TransferDetail.new
    end

    def external_user_type
      :litigator
    end

    def eligible_case_types
      CaseType.lgfs
    end

    def requires_case_concluded_date?
      true
    end

    def requires_case_type?
      false
    end

    def can_have_ppe?
      !transfer_detail.elected_case? || fee_scheme.lgfs_scheme_10?
    end

    private

    # called from state_machine before_submit
    def set_allocation_type
      self.allocation_type = self.transfer_detail.allocation_type
    end

    def provider_delegator
      provider
    end

    def cleaner
      Cleaners::TransferClaimCleaner.new(self)
    end

    def assign_total_attrs
      # TODO: understand if this check is really needed
      # left it here mostly to ensure the new changes do
      # not impact anything API related
      return if from_api?
      assign_fees_total(%i[transfer_fee misc_fees]) if fees_changed?
      assign_expenses_total if expenses_changed?
      return unless total_changes_required?
      assign_total
      assign_vat
    end

    def fees_changed?
      transfer_fee_changed? || misc_fees_changed?
    end

    def total_changes_required?
      fees_changed? || expenses_changed?
    end

    def transfer_fee_changed?
      transfer_fee&.changed?
    end

    def fee_scheme_factory
      FeeSchemeFactory::LGFS
    end
  end
end
