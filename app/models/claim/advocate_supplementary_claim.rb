module Claim
  class AdvocateSupplementaryClaim < BaseClaim
    route_key_name 'advocates_supplementary_claim'

    include ProviderDelegation

    delegate :agfs?, to: :class

    validates_with ::Claim::AdvocateSupplementaryClaimValidator,
                   unless: proc { |c| c.disable_for_state_transition.eql?(:all) }
    validates_with ::Claim::AdvocateSupplementaryClaimSubModelValidator

    before_validation do
      set_supplier_number
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
          { to_stage: :miscellaneous_fees }
        ],
        dependencies: %i[case_details]
      },
      {
        name: :miscellaneous_fees,
        transitions: [
          { to_stage: :travel_expenses }
        ],
        dependencies: %i[case_details defendants]
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
      return if from_api?
      assign_fees_total(%i[misc_fees]) if fees_changed?
      assign_expenses_total if expenses_changed?
      return unless total_changes_required?
      assign_total
      assign_vat
    end

    def total_changes_required?
      fees_changed? || expenses_changed?
    end

    def fees_changed?
      misc_fees_changed?
    end

    def external_user_type
      :advocate
    end

    def final?
      false
    end

    def interim?
      false
    end

    def supplementary?
      true
    end

    def requires_case_type?
      false
    end

    # TODO: SUPPLEMENTARY_CLAIM_TODO promote or mixin/concern
    def eligible_advocate_categories
      Claims::FetchEligibleAdvocateCategories.for(self)
    end

    private

    def cleaner
      Cleaners::AdvocateSupplementaryClaimCleaner.new(self)
    end

    def fee_scheme_factory
      FeeSchemeFactory::AGFS
    end
  end
end
