# frozen_string_literal: true

module Stats
  module ManagementInformation
    class BaseQuery
      include JourneyQueryable
      include ClaimTypeQueryable

      attr_reader :scheme

      def self.call(**kwargs)
        new(kwargs).call
      end

      def initialize(**kwargs)
        @scheme = kwargs[:scheme]&.to_s&.upcase
        @day = kwargs[:day]
        raise ArgumentError, 'scheme must be "agfs" or "lgfs"' if @scheme.present? && %w[AGFS LGFS].exclude?(@scheme)
      end

      def call
        prepare
        ActiveRecord::Base.connection.execute(query)
      end

      private

      def prepare
        ActiveRecord::Base.connection.execute(drop_journeys_func)
        ActiveRecord::Base.connection.execute(create_journeys_func)
      end

      def query
        raise RuntimeError
      end
    end
  end
end
