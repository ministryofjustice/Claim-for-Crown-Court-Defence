class CourtData
  class Defendant
    class Hmcts < Base
      delegate :id, to: :@defendant

      def maat_reference = @defendant.representation_order&.reference || 'No representation order recorded'
      def start = @defendant.representation_order&.start
      def end = @defendant.representation_order&.end
      def contract_number = @defendant.representation_order&.contract_number
    end
  end
end
