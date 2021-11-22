# frozen_string_literal: true

# https://docs.google.com/spreadsheets/d/1LgECNzbhOJ0MPS-2jbsXVyvtS2Q2TnjDQ4o42tyhU_g/edit#gid=1744254165
# Where scheme = AGFS
# And Where submission type = new
# And Where originally submitted = DATE specified for this lookup *
# And Where disk evidence = yes
#

require_relative '../base_count_query'

module Stats
  module ManagementInformation
    module Agfs
      class Af1DiskQuery < BaseCountQuery
        private

        def query
          <<~SQL
            WITH journeys AS (
              #{journeys_query}
            )
            SELECT count(*)
            FROM journeys j
            WHERE j.scheme = '#{@scheme}'
            AND j.journey -> 0 ->> 'to' = 'submitted'
            AND date_trunc('day', j.originally_submitted_at) = '#{@day}'
            AND j.disk_evidence
          SQL
        end
      end
    end
  end
end
