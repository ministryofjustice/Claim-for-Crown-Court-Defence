# frozen_string_literal: true

module Stats
  module ManagementInformation
    class Query
      include JourneyQueryable
      include ClaimTypeQueryable

      attr_reader :scheme

      def self.call(options = {})
        new(options).call
      end

      def initialize(options = {})
        @scheme = options[:scheme]
        raise ArgumentError, 'scheme must be "agfs" or "lgfs"' if @scheme.present? && !@scheme.valid?
      end

      def call
        transform(journeys)
      end

      private

      # OPTIMIZE: need to check performance of this transformation. is it worth the overhead
      def transform(result)
        result.to_a.map(&:deep_symbolize_keys).map do |el|
          el.each_with_object({}) do |(k, v), h|
            h[k] = k.eql?(:journey) ? JSON.parse(v, symbolize_names: true) : v
          end
        end
      end
    end
  end
end
