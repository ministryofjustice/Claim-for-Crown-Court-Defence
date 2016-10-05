module Remote
  class Base
    include ActiveModel::Model
    attr_accessor :id, :created_at, :updated_at

    def remote?; true; end
    def persisted?; true; end

    class << self
      def resource_path
        raise 'not implemented'
      end

      def all(query = {})
        result = client.get(resource_path, query)
        parse_result(result)
      end

      def find(id)
        all.detect { |m| m.id == id }
      end

      private

      def client
        Remote::HttpClient.current
      end

      def parse_result(result)
        result = {items: result} unless result.is_a?(Hash)
        pagination = result.fetch(:pagination, {})
        collection = result.fetch(:items, result).map { |attrs| new(attrs) }

        Remote::Collections::PaginatedCollection.new(collection, pagination)
      end
    end
  end
end
