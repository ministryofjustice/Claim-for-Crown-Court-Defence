module Claim
  module LitigatorCommonValidations
    include ValidateLitigatorSupplierNumber

    def self.included(base)
      base.class_eval do
        def self.first_step_common_validations
          %i[
            case_type
            court
            case_number
            transfer_court
            transfer_case_number
            advocate_category
            offence
            case_concluded_at
          ]
        end
      end
    end

    private

    def validate_creator
      super if defined?(super)
      validate_has_role(@record.creator.try(:provider),
                        :lgfs,
                        :creator,
                        'must be from a provider with permission to submit LGFS claims')
    end

    def validate_advocate_category
      validate_absence(:advocate_category, 'invalid')
    end

    def validate_offence
      validate_presence(:offence, 'blank_class') unless fixed_fee_case?
    end

    def validate_case_concluded_at
      validate_presence(:case_concluded_at, 'blank')
      validate_on_or_after(Settings.earliest_permitted_date, :case_concluded_at, 'check_not_too_far_in_past')
      validate_on_or_before(Date.today, :case_concluded_at, 'check_not_in_future')
    end

    # validate_supplier_number called from ValidateLitigatorSupplierNumber

    # local helpers
    # ---------------------------

    def supplier_number_regex
      SupplierNumber::SUPPLIER_NUMBER_REGEX
    end

    def provider_supplier_numbers
      @record.provider.lgfs_supplier_numbers.pluck(:supplier_number)
    rescue StandardError
      []
    end
  end
end
