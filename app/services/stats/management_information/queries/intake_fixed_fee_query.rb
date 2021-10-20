# frozen_string_literal: true

# https://docs.google.com/spreadsheets/d/1LgECNzbhOJ0MPS-2jbsXVyvtS2Q2TnjDQ4o42tyhU_g/edit#gid=1744254165
# Where scheme = AGFS
# And Where case type name = Appeal against conviction, Appeal against sentence, Breach of Crown Court order, Committal for Sentence, Contempt,  Elected cases not proceeded
# And Where submission type = new
# And Where originally submitted = DATE specified for this lookup *
# And Where disk evidence = no
# And Where claim total < 20,000
# Then show sum of number of submissions meeting the above criteria
#

require_relative 'base_query'

module Stats
  module ManagementInformation
    class IntakeFixedFeeQuery < BaseQuery
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
          AND trim(lower(j.case_type_name)) in ('appeal against conviction', 'appeal against sentence', 'breach of crown court order', 'committal for sentence', 'contempt', 'elected cases not proceeded')
          AND j.journey -> 0 ->> 'to' = 'submitted'
          AND NOT j.disk_evidence
          AND j.claim_total::float < 20000.00
        SQL
      end
    end
  end
end
