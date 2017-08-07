class Fee::BasicFeeValidator < Fee::BaseFeeValidator
  def self.fields
    %i[
      quantity
      rate
      date
    ] + super
  end
end
