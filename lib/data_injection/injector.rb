# A utility class to inject multiple claims.
# example:
#  claims = DataInjection::Queries.claims_with_error("The supplier account code: .* is INVALID!")
#  injector = DataInjection::Injector.new(claims)
#  injector.call
#
module DataInjection
  class Injector
    attr_accessor :claims

    def initialize(claims)
      @claims = claims
    end

    def call
      claims.each do |claim|
        NotificationQueue::AwsClient.new.send!(claim)
      end
    end
  end
end
