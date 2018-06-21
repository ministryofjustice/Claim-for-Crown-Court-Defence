class BasicFeesPresenter < BasePresenter
  presents :basic_fees

  def primary_fee
    basic_fees.select { |b| b.fee_type_code == 'BAF' }.first
  end

  def extra_fees
    basic_fees.select { |b| ['NPW', 'PPE'].include? b.fee_type_code }
  end

  def additional_fees
    basic_fees - [primary_fee] - extra_fees
  end
end
