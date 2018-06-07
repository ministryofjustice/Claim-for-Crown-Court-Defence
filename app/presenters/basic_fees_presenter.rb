class BasicFeesPresenter < BasePresenter
  presents :basic_fees

  def primary_fee
    basic_fees.select { |b| b.fee_type_code == 'BAF' }.first
  end

  def additional_fees
    basic_fees - [primary_fee]
  end
end
