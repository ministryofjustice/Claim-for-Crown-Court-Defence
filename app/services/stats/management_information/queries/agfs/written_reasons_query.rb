# frozen_string_literal: true

# https://docs.google.com/spreadsheets/d/1LgECNzbhOJ0MPS-2jbsXVyvtS2Q2TnjDQ4o42tyhU_g/edit#gid=1744254165
# Where scheme = AGFS
# And Where submission type = written reasons
# And Where originally submitted = DATE specified for this lookup *
#

Dir.glob(File.join(__dir__, '..', 'base_count_query.rb')).each { |f| require_dependency f }

module Stats
  module ManagementInformation
    module Agfs
      class WrittenReasonsQuery < BaseCountQuery
        private

        def query
          <<~SQL
            WITH journeys AS (
              #{journeys_query}
            )
            SELECT count(*)
            FROM journeys j
            WHERE j.scheme = 'AGFS'
            AND j.journey -> 0 ->> 'to' = 'awaiting_written_reasons'
            AND date_trunc('day', j.#{@date_column_filter}) = '#{@day}'
          SQL
        end
      end
    end
  end
end
