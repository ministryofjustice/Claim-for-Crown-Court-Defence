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
    module Queries
      module AGFS
        class IntakeFinalFeeQuery < BaseCountQuery
          acts_as_scheme :agfs

          private

          # NOTE: on time zone edge cases:
          # `completed_at` and `originally_submitted_at` have already been converted to
          # be in 'Europe/London' time but as UTC (i.e. WITHOUT time zone information).
          # Therefore we do not need to use AT TIME ZONE here to handle boundaries issues.
          # see https://www.enterprisedb.com/postgres-tutorials/postgres-time-zone-explained
          #
          # To check details being retrieved you can use this:
          # puts ActiveRecord::Base.connection.execute("WITH journeys AS (#{journeys_query}) select scheme, case_type_name, journey -> 0 ->> 'to' as to_state, date_trunc('day', j.originally_submitted_at) as submitted_at, date_trunc('day', j.completed_at) as completed_at, j.disk_evidence, j.claim_total::float from journeys j").to_a
          #
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
                AND (
                    trim(lower(j.case_type_name)) in ('cracked before retrial', 'cracked trial', 'discontinuance', 'guilty plea', 'retrial', 'trial')
                    OR j.case_type_name is NULL
                    )
                AND j.journey -> 0 ->> 'to' = 'submitted'
                AND NOT j.disk_evidence
                AND j.claim_total::float < 20000.00
              GROUP BY day
            SQL
          end
        end
      end
    end
  end
end
