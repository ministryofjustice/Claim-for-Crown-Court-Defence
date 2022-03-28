# frozen_string_literal: true

# https://docs.google.com/spreadsheets/d/1LgECNzbhOJ0MPS-2jbsXVyvtS2Q2TnjDQ4o42tyhU_g/edit#gid=1744254165
# Where scheme = LGFS
# And Where submission type = redetermination
# And Where originally submitted = DATE specified for this lookup *
# And Where disk evidence = yes
#

Dir.glob(File.join(__dir__, '..', 'base_count_query.rb')).each { |f| require_dependency f }

module Stats
  module ManagementInformation
    module LGFS
      class Lf2DiskQuery < BaseCountQuery
        acts_as_scheme :lgfs

        private

        # OPTIMIZE: this is the sames as Af2DiskQuery
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
              AND j.scheme = 'LGFS'
              AND j.journey -> 0 ->> 'to' = 'redetermination'
              AND j.disk_evidence
            GROUP BY day
          SQL
        end
      end
    end
  end
end
