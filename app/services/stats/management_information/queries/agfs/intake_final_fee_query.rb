# frozen_string_literal: true

# https://docs.google.com/spreadsheets/d/1LgECNzbhOJ0MPS-2jbsXVyvtS2Q2TnjDQ4o42tyhU_g/edit#gid=1744254165
# Where scheme = AGFS
# And Where case type name = Cracked before retrial, cracked trial, discontinuance, guilty plea, retrial, trial, blank
# And Where submission type = new
# And Where originally submitted = DATE specified for this lookup *
# And Where disk evidence = no
# And Where claim total < 20,000
#

require_relative '../base_query'

module Stats
  module ManagementInformation
    module Agfs
      class IntakeFinalFeeQuery < BaseQuery
        private

        # NOTE: on time zone edge cases:
        # j.originally_submitted_at is a date from query that is already
        # "at time zone 'Europe/London'" so, do we need to specify
        # `AND date_trunc('day', j.originally_submitted_at at time zone 'Europe/London') = '#{@day}'`
        # to handle boundaries
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
            AND date_trunc('day', j.originally_submitted_at) = '#{@day}'
            AND NOT j.disk_evidence
            AND j.claim_total::float < 20000.00
          SQL
        end
      end
    end
  end
end
