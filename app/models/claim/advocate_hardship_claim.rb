module Claim
  class AdvocateHardshipClaim < BaseClaim
    route_key_name 'advocates_hardship_claim'

    include ProviderDelegation

    has_many :basic_fees,
             foreign_key: :claim_id,
             class_name: 'Fee::BasicFee',
             dependent: :destroy,
             inverse_of: :claim,
             validate: proc { |claim| claim.step_validation_required?(:basic_fees) }

    delegate :case_type, to: :case_stage, allow_nil: true
    delegate :requires_cracked_dates?, to: :case_type, allow_nil: true
    delegate :agfs?, to: :class

    accepts_nested_attributes_for :basic_fees, reject_if: all_blank_or_zero, allow_destroy: true

    validates_with ::Claim::AdvocateHardshipClaimValidator,
                   unless: proc { |c| c.disable_for_state_transition.eql?(:all) }
    validates_with ::Claim::AdvocateHardshipClaimSubModelValidator

    after_initialize do
      instantiate_basic_fees
    end

    before_validation do
      set_supplier_number
      assign_total_attrs
      assign_trial_cracked_at
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
            to_stage: :offence_details
          }
        ],
        dependencies: %i[case_details]
      },
      {
        name: :offence_details,
        transitions: [
          { to_stage: :basic_fees }
        ],
        dependencies: %i[case_details defendants]
      },
      {
        name: :basic_fees,
        transitions: [
          { to_stage: :miscellaneous_fees }
        ],
        dependencies: %i[case_details defendants offence_details]
      },
      {
        name: :miscellaneous_fees,
        transitions: [
          { to_stage: :travel_expenses }
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

    def assign_total_attrs
      # TODO: understand if this check is really needed
      # left it here mostly to ensure the new changes do
      # not impact anything API related
      return if from_api?
      assign_fees_total(%i[basic_fees misc_fees]) if fees_changed?
      assign_expenses_total if expenses_changed?
      return unless total_changes_required?
      assign_total
      assign_vat
    end

    def total_changes_required?
      fees_changed? || expenses_changed?
    end

    def fees_changed?
      %i[basic misc].any? { |fee_type| public_send(:"#{fee_type}_fees_changed?") }
    end

    def basic_fees_changed?
      basic_fees.any?(&:changed?)
    end

    def eligible_case_types
      eligible_case_stages.map(&:case_type)
    end

    def eligible_case_stages
      CaseStage.agfs.active
    end

    # TODO: Hardship claim - can be shared with advocate final claim
    def eligible_basic_fee_types
      return Fee::BasicFeeType.unscoped.agfs_scheme_10s.order(:position) if agfs_reform?
      Fee::BasicFeeType.agfs_scheme_9s
    end

    def external_user_type
      :advocate
    end

    def case_stage_unique_code=(code)
      self.case_stage = CaseStage.find_by!(unique_code: code)
    end

    def hardship?
      true
    end

    # TODO: Hardship claim - can be shared with all advocate claims
    def eligible_advocate_categories
      Claims::FetchEligibleAdvocateCategories.for(self)
    end

    # rubocop:disable Rails/SkipsModelValidations
    # TODO: Hardship claim - can be shared with advocate final claim
    def update_claim_document_owners
      documents.each { |d| d.update_column(:external_user_id, external_user_id) }
    end
    # rubocop:enable Rails/SkipsModelValidations

    private

    # create a blank fee for every basic fee type not passed to Claim::AdvocateHardshipClaim.new
    def instantiate_basic_fees
      return unless case_type.present? && !case_type.is_fixed_fee?
      return unless editable?

      fee_type_ids = basic_fees.map(&:fee_type_id)
      eligible_basic_fee_type_ids = eligible_basic_fee_types.map(&:id)
      not_eligible_ids = fee_type_ids - eligible_basic_fee_type_ids
      self.basic_fees = basic_fees.reject { |fee| not_eligible_ids.include?(fee.fee_type_id) }
      eligible_basic_fee_types.each do |basic_fee_type|
        next if fee_type_ids.include?(basic_fee_type.id)
        basic_fees.build(fee_type: basic_fee_type, quantity: 0, amount: 0)
      end
    end

    def assign_trial_cracked_at
      return unless requires_cracked_dates?
      return unless editable? || being_submitted?
      self.trial_cracked_at = Time.zone.today
    end

    def being_submitted?
      state_change.eql?(%w[draft submitted])
    end

    def cleaner
      Cleaners::AdvocateHardshipClaimCleaner.new(self)
    end

    def fee_scheme_factory
      FeeSchemeFactory::AGFS
    end
  end
end
