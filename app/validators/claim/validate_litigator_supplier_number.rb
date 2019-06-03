module Claim
  module ValidateLitigatorSupplierNumber
    def validate_supplier_number
      validate_presence(:supplier_number, 'blank')

      return if @record.supplier_number.blank?

      validate_pattern(:supplier_number, supplier_number_regex, 'invalid')
      return if @record.errors.key?(:supplier_number)
      validate_inclusion(:supplier_number, provider_supplier_numbers, 'unknown')
    end
  end
end
