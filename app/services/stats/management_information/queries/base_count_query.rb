# frozen_string_literal: true

module Stats
  module ManagementInformation
    module Queries
      class BaseCountQuery
        include Concerns::JourneyQueryable
        include Concerns::ClaimTypeFilterable

        def self.call(...)
          new(...).call
        end

        def initialize(date_range:, date_column_filter:)
          @start_at = date_range.first.iso8601
          @end_at = date_range.last.iso8601
          @date_column_filter = sql_quote(date_column_filter)
        end

        def call
          prepare
          ActiveRecord::Base.connection.execute(query)
        end

        private

        def sql_quote(column_name)
          ActiveRecord::Base.connection.quote_column_name(column_name)
        end

        def query
          raise RuntimeError
        end
      end
    end
  end
end
