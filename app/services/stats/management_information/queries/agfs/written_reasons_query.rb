# frozen_string_literal: true

# https://docs.google.com/spreadsheets/d/1LgECNzbhOJ0MPS-2jbsXVyvtS2Q2TnjDQ4o42tyhU_g/edit#gid=1744254165
# Where scheme = AGFS
# And Where submission type = written reasons
# And Where originally submitted = DATE specified for this lookup *
#

require_relative '../base_query'

module Stats
  module ManagementInformation
    module Agfs
      class WrittenReasonsQuery < BaseQuery
        private

        def query
          <<~SQL
            WITH journeys AS (
              #{journeys_query}
            )
            SELECT count(*)
            FROM journeys j
            WHERE j.scheme = '#{@scheme}'
            AND date_trunc('day', j.original_submission_date) = '#{@day}'
            AND j.journey -> 0 ->> 'to' = 'awaiting_written_reasons'
          SQL
        end
      end
    end
  end
end
