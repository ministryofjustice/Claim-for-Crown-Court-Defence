# Utility to retrieve claims with injections errors
# Note: use unallocated sql that is used by the apps
# allocation queue to ensure we have only claims that
# have not bee allocated to case workers and can therefore
# be safely reinjected.
#
module DataInjection
  module Queries
    extend API::V2::QueryHelper

    class << self
      def unallocated
        sql = unallocated_sql.gsub(/CLAIM_TYPES_FOR_SCHEME/, claim_types_for_scheme('agfs'))
        ActiveRecord::Base.connection.execute(sql)
      end

      def with_error(error_regex)
        unallocated.select do |rec|
          !rec['injection_errors'].nil? && rec['injection_errors'].match?(error_regex || '.*')
        end
      end

      def claims_with_error(error_regex)
        ::Claim::BaseClaim.where(uuid: with_error(error_regex).pluck('uuid'))
      end

      private

      def in_statement_for(arr)
        arr.map(&:to_s).join('\', \'').prepend('(\'').concat('\')')
      end

      def claim_types_for_scheme(scheme)
        return in_statement_for(::Claim::BaseClaim.agfs_claim_types) if scheme.eql?('agfs')
        in_statement_for(::Claim::BaseClaim.lgfs_claim_types)
      end
    end
  end
end
