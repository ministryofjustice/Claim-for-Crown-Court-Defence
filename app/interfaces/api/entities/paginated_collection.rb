module API
  module Entities
    class PaginatedCollection < BaseEntity
      present_collection true

      expose :pagination do
        expose :current_page
        expose :total_count
        expose :limit_value
      end

      expose :items, using: API::Entities::Claim

      private

      def items
        object[:items]
      end

      def current_page
        options[:pagy].page
      end

      def total_count
        options[:pagy].count
      end

      def limit_value
        options[:pagy].limit
      end
    end
  end
end
