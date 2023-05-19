module Claim
  class AdvocateInterimClaim < BaseClaim
    route_key_name 'advocates_interim_claim'

    include ProviderDelegation

    validates_with ::Claim::AdvocateInterimClaimValidator,
                   unless: proc { |c| c.disable_for_state_transition.eql?(:all) }
    validates_with ::Claim::AdvocateInterimClaimSubModelValidator

    has_one :warrant_fee,
            foreign_key: :claim_id,
            class_name: 'Fee::WarrantFee',
            dependent: :destroy,
            inverse_of: :claim,
            validate: proc { |claim| claim.step_validation_required?(:interim_fees) }

    accepts_nested_attributes_for :warrant_fee, allow_destroy: false

    before_validation do
      set_supplier_number
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

    def external_user_type
      :advocate
    end

    def requires_case_type?
      false
    end

    def agfs?
      true
    end

    def final?
      false
    end

    def interim?
      true
    end

    def eligible_advocate_categories
      Claims::FetchEligibleAdvocateCategories.for(self)
    end

    def fee_scheme_factory
      FeeSchemeFactory::AGFS
    end

    private

    def cleaner
      Cleaners::AdvocateInterimClaimCleaner.new(self)
    end
  end
end
