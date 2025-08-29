class DistanceCalculatorService
  Response = Struct.new(:value, :error)

  def self.call(claim, params)
    new(claim, params).call
  end

  def initialize(claim, params)
    @claim = claim
    @params = params
  end

  def call
    error = validate_inputs
    return Response.new(nil, error) if error

    Response.new(distance(origin, destination), nil)
  end

  private

  attr_reader :claim, :params

  def distance(origin, destination)
    value = DistanceCalculatorService::Directions.new(origin, destination).max_distance

    # NOTE: returned distance is just one way so for the purposes
    # of the travel expense it needs to be a return distance (doubled up)
    2 * value if value
  end

  def validate_inputs
    validate_claim || validate_origin || validate_destination
  end

  def validate_claim
    return :claim_not_found unless claim
    :invalid_claim_type unless claim.lgfs?
  end

  def validate_origin
    :missing_origin unless origin
  end

  def validate_destination
    return :missing_destination unless destination
    :invalid_destination unless destination.match?(Settings.postcode_regexp)
  end

  def origin
    @origin ||= supplier&.postcode
  end

  def destination
    @destination ||= params[:destination]
  end

  def supplier
    return @supplier if defined?(@supplier)

    @supplier = SupplierNumber.find_by(supplier_number: claim.supplier_number)
  end
end
