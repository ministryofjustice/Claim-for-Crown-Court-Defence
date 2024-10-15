class CourtData
  class Defendant
    class Base
      delegate :name, to: :@defendant

      def initialize(defendant:)
        @defendant = defendant
      end

      def ==(other) = maat_reference == other.maat_reference
    end
  end
end
