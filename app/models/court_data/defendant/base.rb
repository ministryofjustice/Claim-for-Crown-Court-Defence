class CourtData
  class Defendant
    class Base
      delegate :name, to: :@defendant

      def initialize(defendant:)
        @defendant = defendant
      end

      def ==(other) = (maat_references & other.maat_references).any?
    end
  end
end
