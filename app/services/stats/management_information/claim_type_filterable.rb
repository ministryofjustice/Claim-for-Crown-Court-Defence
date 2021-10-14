# frozen_string_literal: true

module Stats
  module ManagementInformation
    module ClaimTypeQueryable
      extend ActiveSupport::Concern

      included do
        delegate :claim_types, :agfs_claim_types, :lgfs_claim_types, to: :'::Claim::BaseClaim'

        def claim_type_filter
          return in_statement_for(claim_types) if scheme.blank?
          return in_statement_for(agfs_claim_types) if scheme.eql?(:agfs)
          in_statement_for(lgfs_claim_types)
        end

        def in_statement_for(arr)
          arr.map(&:to_s).join('\', \'').prepend('(\'').concat('\')')
        end
      end
    end
  end
end
