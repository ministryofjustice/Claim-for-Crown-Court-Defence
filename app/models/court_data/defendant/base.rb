class CourtData
  class Defendant
    class Base
      delegate :name, to: :@defendant

      def initialize(defendant:)
        @defendant = defendant
      end

      def ==(other) = maat_references.intersect?(other.maat_references)
    end
  end
end
