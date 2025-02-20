module Claim
  class LitigatorHardshipClaim < BaseClaim
    route_key_name 'litigators_hardship_claim'

    validates_with ::Claim::LitigatorHardshipClaimValidator,
                   unless: proc { |c| c.disable_for_state_transition.eql?(:all) }
    validates_with ::Claim::LitigatorSupplierNumberValidator, if: proc { |c| c.draft? }
    validates_with ::Claim::LitigatorHardshipClaimSubModelValidator

    has_one :hardship_fee,
            foreign_key: :claim_id,
            class_name: 'Fee::HardshipFee',
            dependent: :destroy,
            inverse_of: :claim,
            validate: proc { |claim| claim.step_validation_required?(:hardship_fees) }

    delegate :case_type, to: :case_stage, allow_nil: true
    delegate :lgfs?, to: :class

    accepts_nested_attributes_for :hardship_fee, reject_if: :all_blank, allow_destroy: false

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
          { to_stage: :hardship_fees }
        ],
        dependencies: %i[case_details defendants]
      },
      {
        name: :hardship_fees,
        transitions: [
          { to_stage: :miscellaneous_fees }
        ],
        dependencies: %i[case_details defendants offence_details]
      },
      {
        name: :miscellaneous_fees,
        transitions: [
          { to_stage: :supporting_evidence }
        ],
        dependencies: %i[hardship_fees]
      },
      { name: :supporting_evidence }
    ].freeze

    def hardship?
      true
    end

    # TODO: applicable case types unknown. limiting to trial and retrial for now
    def eligible_case_types
      eligible_case_stages.map(&:case_type)
    end

    def eligible_case_stages
      CaseStage.lgfs.where.not("unique_code LIKE 'OBSOLETE%'")
    end

    def external_user_type
      :litigator
    end

    def case_stage_unique_code=(code)
      self.case_stage = CaseStage.find_by!(unique_code: code)
    end

    private

    def provider_delegator
      provider
    end

    def assign_total_attrs
      # TODO: understand if this check is really needed
      # left it here mostly to ensure the new changes do
      # not impact anything API related
      return if from_api?
      assign_fees_total(%i[hardship_fee misc_fees]) if fees_changed?
      return unless total_changes_required?
      assign_total
      assign_vat
    end

    def total_changes_required?
      [
        hardship_fee_changed?,
        misc_fees_changed?
      ].any?
    end

    def fees_changed?
      hardship_fee_changed? || misc_fees_changed?
    end

    def hardship_fee_changed?
      hardship_fee&.changed?
    end

    def cleaner
      Cleaners::LitigatorHardshipClaimCleaner.new(self)
    end

    def fee_scheme_factory
      FeeSchemeFactory::LGFS
    end
  end
end
