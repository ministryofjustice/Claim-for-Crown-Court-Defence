module Fee
  class HardshipFeeValidator < Fee::BaseFeeValidator
    def self.fields
      %i[
        quantity
      ] + super
    end

    def validate_amount
      validate_presence_and_numericality_govuk_formbuilder(:amount, minimum: 0.1)
    end

    # ppe
    def validate_quantity
      validate_presence_and_numericality_govuk_formbuilder(:quantity, minimum: 0)
    end
  end
end
