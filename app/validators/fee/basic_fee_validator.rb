class Fee::BasicFeeValidator < Fee::BaseFeeValidator

  def self.fields
    [
      :quantity,
      :rate,
      :date
    ] + super
  end

end
