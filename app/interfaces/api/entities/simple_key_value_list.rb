module API
  module Entities
    class SimpleKeyValueList < BaseEntity
      expose :id
      expose :description

      private

      def id
        object.first
      end

      def description
        object.last
      end
    end
  end
end
