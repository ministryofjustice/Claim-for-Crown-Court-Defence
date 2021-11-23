# frozen_string_literal: true

# https://docs.google.com/spreadsheets/d/1LgECNzbhOJ0MPS-2jbsXVyvtS2Q2TnjDQ4o42tyhU_g/edit#gid=1744254165
# Where scheme = AGFS
# And Where case type name = Cracked before retrial, cracked trial, discontinuance, guilty plea, retrial, trial, blank
# And Where submission type = new
# And Where originally submitted = DATE specified for this lookup *
# And Where disk evidence = no
# And Where claim total < 20,000
#

Dir.glob(File.join(__dir__, '..', 'base_count_query.rb')).each { |f| require_dependency f }

module Stats
  module ManagementInformation
    module Agfs
      class IntakeFinalFeeQuery < BaseCountQuery
        private

        # NOTE: on time zone edge cases:
        # `completed_at` and `originally_submitted_at` have already been converted to
        # be in 'Europe/London' time WITHOUT time zone information.
        # Therefore we do not need to use AT TIME ZONE here to handle
        # boundaries issues.
        # see https://www.enterprisedb.com/postgres-tutorials/postgres-time-zone-explained
        #
        def query
          <<~SQL
            WITH journeys AS (
              #{journeys_query}
            )
            SELECT count(*)
            FROM journeys j
            WHERE j.scheme = '#{@scheme}'
            AND (
                trim(lower(j.case_type_name)) in ('cracked before retrial', 'cracked trial', 'discontinuance', 'guilty plea', 'retrial', 'trial')
                OR j.case_type_name is NULL
                )
            AND j.journey -> 0 ->> 'to' = 'submitted'
            AND date_trunc('day', j.#{@date_column_filter}) = '#{@day}'
            AND NOT j.disk_evidence
            AND j.claim_total::float < 20000.00
          SQL
        end
      end
    end
  end
end
