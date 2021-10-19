# frozen_string_literal: true

# https://docs.google.com/spreadsheets/d/1LgECNzbhOJ0MPS-2jbsXVyvtS2Q2TnjDQ4o42tyhU_g/edit#gid=1744254165
# Where scheme = AGFS
# And Where submission type = new
# And Where originally submitted = DATE specified for this lookup *
# And Where disk evidence = yes
#
module Stats
  module ManagementInformation
    class Af1DiskQuery < BaseQuery
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
          AND j.journey -> 0 ->> 'to' = 'submitted'
          AND j.disk_evidence
          AND j.claim_total::float < 20000.00
        SQL
      end
    end
  end
end
