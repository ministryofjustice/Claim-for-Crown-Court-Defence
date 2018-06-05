module API
  module V2
    class Search < Grape::API
      helpers API::V2::CriteriaHelper
      helpers API::V2::QueryHelper

      resource :search, desc: 'Search for claims' do
        params do
          optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
          optional :scheme,
                   type: String,
                   default: 'agfs',
                   values: %w[agfs lgfs],
                   desc: 'OPTIONAL: This will be used to filter the list of unallocated claims'
        end

        helpers do
          def in_statement_for(arr)
            arr.map(&:to_s).join('\', \'').prepend('(\'').concat('\')')
          end

          def claim_types_for_scheme
            return in_statement_for(::Claim::BaseClaim.agfs_claim_types) if scheme.eql?('agfs')
            in_statement_for(::Claim::BaseClaim.lgfs_claim_types)
          end

          def claims
            built_sql = unallocated_sql.gsub(/CLAIM_TYPES_FOR_SCHEME/, claim_types_for_scheme)
            result = ActiveRecord::Base.connection.execute(built_sql).to_a
            JSON.parse(result.to_json, object_class: OpenStruct)
          end

          def scheme
            params[:scheme]
          end
        end

        resource :unallocated do
          desc 'Retrieve list of unallocated claims'
          get do
            present claims, with: API::Entities::SearchResult, user: current_user, content_encoding: 'gzip'
          end
        end
      end
    end
  end
end
