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

      def initialize(day:, date_column_filter:)
        @day = day.to_date.iso8601
        @date_column_filter = sql_quote(date_column_filter)
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

      def sql_quote(column_name)
        ActiveRecord::Base.connection.quote_column_name(column_name)
      end

      def query
        raise RuntimeError
      end
    end
  end
end
