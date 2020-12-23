module ProviderDelegation
  extend ActiveSupport::Concern

  included do
    def provider_delegator
      if provider.firm?
        provider
      elsif provider.chamber?
        external_user
      else
        raise "Unknown provider type: #{provider.provider_type}"
      end
    end

    def agfs_supplier_number
      return provider.firm_agfs_supplier_number if provider.firm?
      external_user.supplier_number
    rescue StandardError
      nil
    end

    def set_supplier_number
      supplier_no = agfs_supplier_number
      self.supplier_number = supplier_no if supplier_number != supplier_no
    end
  end
end
