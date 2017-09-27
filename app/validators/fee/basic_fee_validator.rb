module Fee
  class BasicFeeValidator < Fee::BaseFeeValidator
    include Concerns::Agfs::CaseNumbersValidator

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
