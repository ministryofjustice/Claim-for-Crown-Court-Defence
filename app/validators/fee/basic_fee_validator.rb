module Fee
  class BasicFeeValidator < Fee::BaseFeeValidator
    include Concerns::CaseNumbersValidator

    def self.fields
      %i[
        quantity
        rate
        date
        case_numbers
      ] + super
    end
  end
end
