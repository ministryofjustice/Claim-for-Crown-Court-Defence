module Claim
  class AdvocateSupplementaryClaim < BaseClaim
    route_key_name 'advocates_supplementary_claim'

    # TODO: SUPPLEMENTARY_CLAIM_TODO override base claim relation to enforce ??
    # has_many :fees,
    #           foreign_key: :claim_id,
    #           class_name: 'Fee::MiscFee',
    #           dependent: :destroy,
    #           inverse_of: :claim,
    #           validate: proc { |claim| claim.step_validation_required?(:miscellaneous_fees) }

    # TODO: SUPPLEMENTARY_CLAIM_TODO check this overrides base claim accepts_nested_attributes_for
    accepts_nested_attributes_for :misc_fees, reject_if: all_blank_or_zero, allow_destroy: true

    validates_with ::Claim::AdvocateSupplementaryClaimValidator,
                   unless: proc { |c| c.disable_for_state_transition.eql?(:all) }
    validates_with ::Claim::AdvocateSupplementaryClaimSubModelValidator

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

    def external_user_type
      :advocate
    end

    def agfs?
      self.class.agfs?
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

    def eligible_case_types
      CaseType.agfs
    end

    def eligible_advocate_categories
      Claims::FetchEligibleAdvocateCategories.for(self)
    end

    def eligible_misc_fee_types
      Claims::FetchEligibleMiscFeeTypes.new(self).call
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
