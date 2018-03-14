module Claim
  class AdvocateInterimClaim < BaseClaim
    route_key_name 'advocates_interim_claim'

    validates_with ::Claim::AdvocateInterimClaimValidator,
                   unless: proc { |c| c.disable_for_state_transition.eql?(:all) }
    validates_with ::Claim::AdvocateInterimClaimSubModelValidator

    before_validation do
      set_supplier_number
    end

    def submission_stages
      %i[case_details defendants offence_details fees]
    end

    def external_user_type
      :advocate
    end

    def requires_case_type?
      false
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
