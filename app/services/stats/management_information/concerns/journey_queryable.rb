# frozen_string_literal: true

require_relative 'claim_type_filterable'

module Stats
  module ManagementInformation
    module JourneyQueryable
      extend ActiveSupport::Concern

      included do
        def prepare
          SqlQuery.new('journey/drop_func').execute(false)
          SqlQuery.new('journey/create_func').execute(false)
        end

        def journeys_query
          SqlQuery.new('journey/query',
                       claim_type_filter: claim_type_filter,
                       in_agfs_claim_types: in_statement_for(agfs_claim_types),
                       in_lgfs_claim_types: in_statement_for(lgfs_claim_types))
        end
      end
    end
  end
end
