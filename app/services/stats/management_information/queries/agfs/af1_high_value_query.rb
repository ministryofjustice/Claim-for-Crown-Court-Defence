# frozen_string_literal: true

# https://docs.google.com/spreadsheets/d/1LgECNzbhOJ0MPS-2jbsXVyvtS2Q2TnjDQ4o42tyhU_g/edit#gid=1744254165
# Where scheme = AGFS
# And Where submission type = new
# And Where originally submitted = DATE specified for this lookup *
# And Where disk evidence = no
# And Where claim total >= 20,000
# Then show sum of number of submissions meeting the above criteria
#

Dir.glob(File.join(__dir__, '..', 'base_count_query.rb')).each { |f| require_dependency f }

module Stats
  module ManagementInformation
    module AGFS
      class Af1HighValueQuery < BaseCountQuery
        acts_as_scheme :agfs

        private

        def query
          <<~SQL
            WITH days AS (
              SELECT day::date
              FROM generate_series('#{@start_at}', '#{@end_at}', '1 day'::interval) day
            ),
            journeys AS (
              #{journeys_query}
            )
            SELECT count(j.*), date_trunc('day', d.day) as day
            FROM days d
            LEFT OUTER JOIN journeys j
              ON date_trunc('day', j.#{@date_column_filter}) = d.day
              AND j.scheme = 'AGFS'
              AND j.journey -> 0 ->> 'to' = 'submitted'
              AND NOT j.disk_evidence
              AND j.claim_total::float >= 20000.00
            GROUP BY day
          SQL
        end
      end
    end
  end
end
