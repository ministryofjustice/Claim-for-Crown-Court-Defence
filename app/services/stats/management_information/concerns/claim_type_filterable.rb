# frozen_string_literal: true

module Stats
  module ManagementInformation
    module Concerns
      module ClaimTypeFilterable
        extend ActiveSupport::Concern

        class_methods do
          def acts_as_scheme(scheme)
            define_method(:scheme) do
              scheme&.to_s&.upcase
            end
          end
        end

        included do
          def scheme
            @scheme&.to_s&.upcase
          end

          def scheme=(scheme)
            @scheme = scheme&.to_s&.upcase
          end

          delegate :claim_types, :agfs_claim_types, :lgfs_claim_types, to: :base_claim_klass

          def base_claim_klass
            ::Claim::BaseClaim
          end

          def claim_type_filter
            return in_statement_for(agfs_claim_types) if scheme.eql?('AGFS')
            return in_statement_for(lgfs_claim_types) if scheme.eql?('LGFS')
            in_statement_for(claim_types)
          end

          def in_statement_for(arr)
            arr.map(&:to_s).join('\', \'').prepend('(\'').concat('\')')
          end
        end
      end
    end
  end
end
