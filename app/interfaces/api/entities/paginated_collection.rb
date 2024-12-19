module API
  module Entities
    class PaginatedCollection < BaseEntity
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

      def pagination
        options[:pagy]
      end

      def current_page
        pagination.page
      end

      def total_pages
        pagination.pages
      end

      def total_count
        pagination.count
      end

      def limit_value
        pagination.limit
      end
    end
  end
end
