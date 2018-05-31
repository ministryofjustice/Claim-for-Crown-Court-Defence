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

    private

    # TODO: There's no real reason for this validation to accept 0 quantities.
    # Still, given that the basic fees are being pre-set whenever a claim is initializing
    # (rather than create them whenever they're actually needed) those pre-sets would not be
    # valid if the quantity validation checked for greater or equal than 1 (which should be the right
    # validation to perform on any fee created).
    # Until we address that pre-initialization of the basic fees, this preserves the existent validation
    # for basic fees
    def validate_any_quantity
      validate_integer_decimal
      add_error(:quantity, 'invalid') if @record.quantity.negative? || @record.quantity > 99_999
    end
  end
end
