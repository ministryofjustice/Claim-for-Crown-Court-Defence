# frozen_string_literal: true

module Stats
  module ManagementInformation
    class BaseCountQuery
      include JourneyQueryable
      include ClaimTypeQueryable

      attr_reader :scheme

      def self.call(**kwargs)
        new(kwargs).call
      end

      def initialize(scheme:, day:, date_column_filter:)
        @scheme = scheme&.to_s&.upcase
        @day = day
        @date_column_filter = date_column_filter
        raise ArgumentError, 'scheme must be "agfs" or "lgfs"' if %w[AGFS LGFS].exclude?(@scheme)
        raise ArgumentError, 'day must be provided' if @day.blank?
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
