class BasicFeesPresenter < BasePresenter
  presents :basic_fees

  FEE_CODES_FOR_EXTRA_FEES = %w[NPW PPE].freeze

  def primary_fee
    basic_fees.find { |b| b.fee_type_code == 'BAF' }
  end

  def extra_fees
    basic_fees.select { |b| FEE_CODES_FOR_EXTRA_FEES.include? b.fee_type_code }
  end

  def additional_fees
    basic_fees - [primary_fee] - extra_fees
  end
end
