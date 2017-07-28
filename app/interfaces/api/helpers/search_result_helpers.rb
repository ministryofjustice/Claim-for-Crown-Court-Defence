module SearchResultHelpers
  private

  def fees
    object.fees&.split(',')&.map { |fee| fee.split('~') }
  end

  def graduated_fee_codes
    object.graduated_fee_types&.split(',')
  end

  def fee_is_interim_type
    fees.map do |fee|
      [
        fee[2].eql?('Fee::InterimFeeType'),
        fee[1].downcase.in?(['effective pcmh', 'trial start', 'retrial new solicitor', 'retrial start'])
      ].all?
    end.any?
  end

  def contains_risk_based_fee
    fees&.map do |fee|
      [
        fee[0].to_i.between?(1, 50),
        fee[1].eql?('Guilty plea'),
        fee[2].eql?('Fee::GraduatedFeeType')
      ]&.all?
    end&.any?
  end

  def contains_fee_of_type(fee_type_description)
    fees&.map do |fee|
      [
        fee[2].eql?('Fee::InterimFeeType'),
        fee[1].eql?(fee_type_description)
      ].all?
    end.any?
  end

  def risk_based_class_letter
    object.class_letter&.in?(%w(E F H I))
  end

  def interim_claim?
    object.scheme_type.eql?('Interim')
  end
end
