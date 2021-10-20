# frozen_string_literal: true

# https://docs.google.com/spreadsheets/d/1LgECNzbhOJ0MPS-2jbsXVyvtS2Q2TnjDQ4o42tyhU_g/edit#gid=1744254165
# Where scheme = AGFS
# And Where submission type = redetermination
# And Where originally submitted = DATE specified for this lookup *
# And Where disk evidence = yes
#

require_relative 'base_query'

module Stats
  module ManagementInformation
    class Af2DiskQuery < BaseQuery
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
          AND j.journey -> 0 ->> 'to' = 'redetermination'
          AND j.disk_evidence
        SQL
      end
    end
  end
end
