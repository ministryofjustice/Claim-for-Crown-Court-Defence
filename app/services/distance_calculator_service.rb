class DistanceCalculatorService
  def self.call(claim, params)
    new(claim, params).call
  end

  def initialize(claim, params)
    @claim = claim
    @params = params
  end

  def call
    response.tap do |data|
      data.value =  DistanceCalculatorService::Directions.new(origin, destination).max_distance unless data.error
      # NOTE: returned distance is just one way so for the purposes
      # of the travel expense it needs to be a return distance (doubled up)
      data.value *= 2 if data.value
    end
  end

  private

  attr_reader :claim, :params

  def response
    OpenStruct.new(value: nil, error: validate_inputs)
  end

  def validate_inputs
    validate_claim || validate_origin || validate_destination
  end

  def validate_claim
    return :claim_not_found unless claim
    return :invalid_claim_type unless claim.lgfs?
  end

  def validate_origin
    return :missing_origin unless origin
  end

  def validate_destination
    return :missing_destination unless destination
    return :invalid_destination unless destination.match?(Settings.postcode_regexp)
  end

  def origin
    @origin ||= supplier&.postcode
  end

  def destination
    @destination ||= params[:destination]
  end

  def supplier
    @supplier ||= SupplierNumber.find_by(supplier_number: claim.supplier_number)
  end
end
