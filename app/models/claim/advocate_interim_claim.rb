module Claim
  class AdvocateInterimClaim < BaseClaim
    route_key_name 'advocates_interim_claim'

    validates_with ::Claim::AdvocateInterimClaimValidator,
                   unless: proc { |c| c.disable_for_state_transition.eql?(:all) }
    validates_with ::Claim::AdvocateInterimClaimSubModelValidator

    has_one :warrant_fee, foreign_key: :claim_id, class_name: 'Fee::WarrantFee', dependent: :destroy, inverse_of: :claim

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
          {
            to_stage: :offence_details,
            condition: ->(claim) { !claim.fixed_fee_case? }
          },
          {
            to_stage: :basic_and_fixed_fees,
            condition: ->(claim) { claim.fixed_fee_case? }
          }
        ]
      },
      {
        name: :offence_details,
        transitions: [
          { to_stage: :interim_fees }
        ]
      },
      {
        name: :interim_fees,
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

    private

    def agfs_supplier_number
      if provider.firm?
        provider.firm_agfs_supplier_number
      else
        external_user.supplier_number
      end
    rescue StandardError
      nil
    end

    def provider_delegator
      if provider.firm?
        provider
      elsif provider.chamber?
        external_user
      else
        raise "Unknown provider type: #{provider.provider_type}"
      end
    end

    def set_supplier_number
      supplier_no = agfs_supplier_number
      self.supplier_number = supplier_no if supplier_number != supplier_no
    end
  end
end
