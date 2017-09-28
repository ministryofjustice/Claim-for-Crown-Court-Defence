module Fee
  class MiscFeeValidator < Fee::BaseFeeValidator
    include Concerns::CaseNumbersValidator

    def self.fields
      %i[
        quantity
        rate
        case_numbers
      ] + super
    end

    private

    def validate_quantity
      super if run_base_fee_validators?
    end

    def validate_rate
      super if run_base_fee_validators?
    end

    def validate_amount
      if run_base_fee_validators? || fee_code.nil?
        super
      else
        validate_presence_and_numericality(:amount, minimum: 0.1)
      end
    end

    def run_base_fee_validators?
      !@record.claim.lgfs?
    end
  end
end
