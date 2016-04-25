module Claim
  module LitigatorCommonValidations

    private

    def validate_creator
      super if defined?(super)
      validate_has_role(@record.creator.try(:provider), :lgfs, :creator, 'must be from a provider with permission to submit LGFS claims')
    end

    def validate_advocate_category
      validate_absence(:advocate_category, "invalid")
    end

    def validate_offence
      validate_presence(:offence, "blank")
      validate_inclusion(:offence, Offence.miscellaneous.to_a, "invalid")
    end

    def validate_case_concluded_at
      validate_presence(:case_concluded_at, 'blank')
    end

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
      @record.provider.supplier_numbers.pluck(:supplier_number) rescue []
    end
  end
end