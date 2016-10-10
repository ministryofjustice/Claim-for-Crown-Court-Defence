module API
  module Entities
    class PaginatedCollection < Grape::Entity
      present_collection true

      expose :pagination do
        expose :current_page
        expose :total_pages
        expose :total_count
        expose :limit_value
      end

      expose :items, using: API::Entities::Claim

      private

      def items
        object[:items]
      end

      def current_page
        items.current_page
      end

      def total_pages
        items.total_pages
      end

      def total_count
        items.total_count
      end

      def limit_value
        items.limit_value
      end
    end
  end
end
