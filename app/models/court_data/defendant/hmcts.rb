class CourtData
  class Defendant
    class Hmcts < Base
      delegate :id, to: :@defendant

      def maat_references = @defendant.representation_orders.map(&:reference)
      def start = @defendant.representation_order&.start
      def end = @defendant.representation_order&.end
      def contract_number = @defendant.representation_order&.contract_number

      def maat_reference_list
        return 'No representation orders recorded' if maat_references.empty?

        maat_references.join(', ')
      end
    end
  end
end
