class DistanceCalculatorService
  Response = Struct.new(:value, :error)

  def self.call(claim, params)
    new(claim, params).call
  end

  def initialize(claim, params)
    @claim = claim
    @params = params
    @client = GoogleMaps::Directions::Client.new
  end

  def call
    error = validate_inputs
    return Response.new(nil, error) if error

    Response.new(distance, nil)
  end

  private

  attr_reader :claim, :params, :client

  # NOTE: returned distance is just one way so for the purposes
  # of the travel expense it needs to be a round-trip (i.e. doubled)
  #
  def distance
    result = client.directions(origin: origin, destination: destination)
    distance = result.distances.max

    2 * distance.value if distance.value
  rescue GoogleMaps::Directions::Error => e
    log(action: __method__, error: e, level: :error) { "Failed to calculate distance" }
    nil
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

  def log(action: nil, error: nil, level: :info)
    LogStuff.send(
      level,
      class: self.class,
      action: action,
      origin: origin,
      destination: destination,
      error: error ? "#{error.class} - #{error.message}" : 'false'
    ) do
      yield
    end
  end
end
