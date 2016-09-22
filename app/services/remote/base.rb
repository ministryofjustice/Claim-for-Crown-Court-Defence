module Remote
  class Base
    include ActiveModel::Model
    attr_accessor :id, :created_at, :updated_at

    class << self
      def resource_path
        raise 'not implemented'
      end

      def resource_ttl
        86400 # override in subclasses if necessary
      end

      # Add * as a temporary measure so that we can easily see in the UI
      # that it is using the API to get data, not the DB.
      #
      def all
        client.get(resource_path, ttl: resource_ttl).map { |h| new(h.merge(name: h['name'] += ' *')) }
      end

      def find(id)
        all.detect { |m| m.id == id }
      end

      private

      def client
        Remote::HttpClient.current
      end
    end
  end
end
