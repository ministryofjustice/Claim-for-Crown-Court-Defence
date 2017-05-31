module Claim
  module LitigatorSupplierNumberValidations

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

    def validate_supplier_number
      validate_presence(:supplier_number, 'blank')

      return unless @record.supplier_number.present?

      validate_pattern(:supplier_number, supplier_number_regex, 'invalid')
      validate_inclusion(:supplier_number, provider_supplier_numbers, 'unknown') unless @record.errors.key?(:supplier_number)
    end


    # local helpers
    # ---------------------------


    def supplier_number_regex
      SupplierNumber::SUPPLIER_NUMBER_REGEX
    end

    def provider_supplier_numbers
      @record.provider.lgfs_supplier_numbers.pluck(:supplier_number) rescue []
    end
  end
end
