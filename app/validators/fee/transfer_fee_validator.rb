class Fee::TransferFeeValidator < Fee::BaseFeeValidator
  def self.fields
    %i[
      quantity
    ] + super
  end

  def validate_amount
    validate_presence_and_numericality(:amount, minimum: 0.1)
  end

  def validate_quantity
    if @record.claim&.transfer_detail&.ppe_required?
      validate_presence_and_numericality(:quantity, minimum: 1)
    else
      validate_presence_and_numericality(:quantity, minimum: 0)
    end
  end
end
