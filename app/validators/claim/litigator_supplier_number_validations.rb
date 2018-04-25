module Claim
  module LitigatorSupplierNumberValidations
    include ValidateLitigatorSupplierNumber

    def self.included(base)
      base.class_eval do
        def self.first_step_common_validations
          [
            :supplier_number
          ]
        end
      end
    end

    private

    # validate_supplier_number called from ValidateLitigatorSupplierNumber

    def supplier_number_regex
      SupplierNumber::SUPPLIER_NUMBER_REGEX
    end

    def provider_supplier_numbers
      @record.provider.reload.lgfs_supplier_numbers.pluck(:supplier_number)
    rescue StandardError
      []
    end
  end
end
