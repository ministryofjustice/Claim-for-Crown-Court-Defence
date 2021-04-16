require 'dry/monads/all'

class DistanceCalculatorService
  include Dry::Monads

  def self.call(claim, params)
    new(claim, params).call
  end

  def initialize(claim, params)
    @claim = claim
    @params = params
  end

  def call
    return validation_error unless valid_inputs?
    distance = DistanceCalculatorService::Directions.new(origin, destination).max_distance

    return Success.new(nil) unless distance
    # NOTE: returned distance is just one way so for the purposes
    # of the travel expense it needs to be a return distance (doubled up)
    Success.new(distance * 2)
  end

  private

  attr_reader :claim, :params
  attr_accessor :validation_error

  def valid_inputs?
    result = validate_inputs
    self.validation_error = result unless result.success?
    validation_error.nil?
  end

  def validate_inputs
    validate_claim
    validate_origin
    validate_destination

    Success.new(:valid)
  rescue RuntimeError => e
    Failure.new(e.message.to_sym)
  end

  def validate_claim
    raise 'claim_not_found' unless claim
    raise 'invalid_claim_type' unless claim.lgfs?
  end

  def validate_origin
    raise 'missing_origin' unless origin
  end

  def validate_destination
    raise 'missing_destination' unless destination
    raise 'invalid_destination' unless destination.match?(Settings.postcode_regexp)
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
