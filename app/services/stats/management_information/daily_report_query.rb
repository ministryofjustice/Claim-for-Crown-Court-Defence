# frozen_string_literal: true

Dir[File.join(__dir__, 'concerns', '*.rb')].each { |f| require_dependency f }
Dir[File.join(__dir__, 'queries', '*.rb')].each { |f| require_dependency f }

module Stats
  module ManagementInformation
    class DailyReportQuery
      include Concerns::JourneyQueryable
      include Concerns::ClaimTypeFilterable

      def self.call(...)
        new(...).call
      end

      def initialize(**kwargs)
        self.scheme = kwargs[:scheme]
        raise ArgumentError, 'scheme must be "agfs" or "lgfs"' if @scheme.present? && %w[AGFS LGFS].exclude?(@scheme)
      end

      def call
        prepare
        transform(journeys)
      end

      private

      def journeys
        ActiveRecord::Base.connection.execute(journeys_query)
      end

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
