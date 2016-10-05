module Remote
  module Collections
    class PaginatedCollection < SimpleDelegator
      attr_accessor :current_page, :total_pages, :total_count, :limit_value

      def initialize(collection = [], pagination = {})
        super(collection)
        pagination.each { |key, value| send("#{key}=", value) }
      end

      def remote?
        true
      end
    end
  end
end
