module Claim
  module LitigatorCommonValidations

    def self.included(base)
      base.class_eval do
        def self.first_step_common_validations
          [
            :case_type,
            :court,
            :case_number,
            :transfer_court,
            :transfer_case_number,
            :advocate_category,
            :offence,
            :case_concluded_at
          ]
        end
      end
    end

    private

    def validate_creator
      super if defined?(super)
      validate_has_role(@record.creator.try(:provider), :lgfs, :creator, 'must be from a provider with permission to submit LGFS claims')
    end

    def validate_advocate_category
      validate_absence(:advocate_category, "invalid")
    end

    def validate_offence
      validate_presence(:offence, "blank_class")
      validate_inclusion(:offence, Offence.miscellaneous.to_a, "invalid_class")
    end

    def validate_case_concluded_at
      validate_presence(:case_concluded_at, 'blank')
      validate_not_before(Settings.earliest_permitted_date, :case_concluded_at, 'check_not_too_far_in_past')
      validate_not_after(Date.today, :case_concluded_at, 'check_not_in_future')
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