class CourtData
  class Defendant
    class Claim < Base
      def maat_references = @defendant.representation_orders.map(&:maat_reference)
    end
  end
end
