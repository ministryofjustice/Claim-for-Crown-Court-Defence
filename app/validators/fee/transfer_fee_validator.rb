module Fee
  class TransferFeeValidator < Fee::BaseFeeValidator
    def self.fields
      %i[
        quantity
      ] + super
    end

    def validate_amount
      validate_presence_and_numericality_govuk_formbuilder(:amount, minimum: 0.1)
    end

    def validate_quantity
      if @record.claim&.transfer_detail&.ppe_required?
        validate_presence_and_numericality_govuk_formbuilder(:quantity, minimum: 1)
      else
        validate_presence_and_numericality_govuk_formbuilder(:quantity, minimum: 0)
      end
    end
  end
end
