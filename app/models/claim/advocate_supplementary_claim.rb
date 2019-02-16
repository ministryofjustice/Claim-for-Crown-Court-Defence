module Claim
  class AdvocateSupplementaryClaim < BaseClaim
    route_key_name 'advocates_supplementary_claim'

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

    def requires_case_type?
      false
    end

    # TODO: SUPPLEMENTARY_CLAIM_TODO promote or mixin/concern
    def eligible_advocate_categories
      Claims::FetchEligibleAdvocateCategories.for(self)
    end

    # TODO: SUPPLEMENTARY_CLAIM_TODO promote or mixin/concern
    def eligible_misc_fee_types
      Claims::FetchEligibleMiscFeeTypes.new(self).call
    end

    private

    # TODO: SUPPLEMENTARY_CLAIM_TODO mixin/conceern Claims::AdvocateClaimProviderDelegation??
    def agfs_supplier_number
      if provider.firm?
        provider.firm_agfs_supplier_number
      else
        external_user.supplier_number
      end
    rescue StandardError
      nil
    end

    # TODO: SUPPLEMENTARY_CLAIM_TODO mixin/concern Claims::AdvocateClaimProviderDelegation??
    def provider_delegator
      if provider.firm?
        provider
      elsif provider.chamber?
        external_user
      else
        raise "Unknown provider type: #{provider.provider_type}"
      end
    end

    # TODO: SUPPLEMENTARY_CLAIM_TODO mixin/concern Claims::AdvocateClaimProviderDelegation??
    def set_supplier_number
      supplier_no = agfs_supplier_number
      self.supplier_number = supplier_no if supplier_number != supplier_no
    end

    def cleaner
      AdvocateSupplementaryClaimCleaner.new(self)
    end
  end
end
