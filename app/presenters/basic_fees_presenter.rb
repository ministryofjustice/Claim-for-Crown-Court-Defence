class BasicFeesPresenter < BasePresenter
  presents :basic_fees

  def primary_fee
    basic_fees.find_by(fee_type_code: 'BAF')
  end

  def extra_fees
    basic_fees.select { |b| %w[NPW PPE].include? b.fee_type_code }
  end

  def additional_fees
    basic_fees - [primary_fee] - extra_fees
  end
end
