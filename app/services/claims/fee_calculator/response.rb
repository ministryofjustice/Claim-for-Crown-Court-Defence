# Struct to share expected fee calc api response
# in a standardised data container.
#
module Claims
  module FeeCalculator
    Response = Struct.new(:success?, :data, :errors, :message)
  end
end
