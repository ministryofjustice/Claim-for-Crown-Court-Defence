# frozen_string_literal: true

# https://docs.google.com/spreadsheets/d/1LgECNzbhOJ0MPS-2jbsXVyvtS2Q2TnjDQ4o42tyhU_g/edit#gid=1744254165
# Where scheme = LGFS
# And Where submission type = redetermination
# And Where originally submitted = DATE specified for this lookup *
# And Where disk evidence = yes
#

require_relative '../base_query'

module Stats
  module ManagementInformation
    module Lgfs
      class Lf2DiskQuery < BaseQuery
        private

        # OPTIMIZE: this is the sames as Af2DiskQuery
        def query
          <<~SQL
            WITH journeys AS (
              #{journeys_query}
            )
            SELECT count(*)
            FROM journeys j
            WHERE j.scheme = '#{@scheme}'
            AND j.journey -> 0 ->> 'to' = 'redetermination'
            AND date_trunc('day', j.original_submission_date) = '#{@day}'
            AND j.disk_evidence
          SQL
        end
      end
    end
  end
end
