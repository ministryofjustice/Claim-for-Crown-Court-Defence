module API
  module Entities
    class ExpenseReasonSet < Grape::Entity
      expose :reason_set
      expose :reasons, using: API::Entities::ExpenseReason

      private

      def reason_set
        object.keys.first
      end

      def reasons
        object.values.first
      end
    end
  end
end
