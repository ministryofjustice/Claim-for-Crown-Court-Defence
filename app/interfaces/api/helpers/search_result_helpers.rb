module SearchResultHelpers
  private

  def fee_is_interim_type
    object.fees.map do |fee|
      [
        fee.fee_type.is_a?(::Fee::InterimFeeType),
        fee.fee_type.description.in?(['Effective PCMH', 'Trial Start', 'Retrial New Solicitor', 'Retrial Start'])
      ].all?
    end.any?
  end

  def risk_based_class_letter
    if object.offence.present?
      %w(E F H I).include?(object.offence.offence_class.class_letter)
    else
      false
    end
  end

  def contains_risk_based_fee
    object.fees.map do |fee|
      [
        fee.quantity.between?(1, 50),
        fee.fee_type.description == 'Guilty plea',
        fee.fee_type.is_a?(::Fee::GraduatedFeeType)
      ].all?
    end.any?
  end

  def interim_claim?
    object.is_a?(::Claim::InterimClaim)
  end

  def contains_fee_of_type(fee_type_description)
    object.fees.map do |fee|
      [
        fee.fee_type.is_a?(::Fee::InterimFeeType),
        fee.fee_type.description.eql?(fee_type_description)
      ].all?
    end.any?
  end
end
