module API
  module V2
    class Search < Grape::API
      helpers API::V2::CriteriaHelper

      resource :search, desc: 'Search for claims' do
        params do
          optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
          optional :scheme,
                   type: String,
                   values: %w(agfs lgfs),
                   default: 'agfs',
                   desc: 'OPTIONAL: This will be used to filter the list of unallocated claims'
        end

        helpers do
          def claims
            ::Claim::BaseClaim
              .active.__send__(scheme)
              .submitted_or_redetermination_or_awaiting_written_reasons
              .includes(:case_type,
                        :court,
                        :claim_state_transitions,
                        :external_user,
                        :fees,
                        :messages => :user_message_statuses,
                        :defendants => :representation_orders,
                        :offence => :offence_class
              )
          end

          def scheme
            params.scheme
          end
        end

        resource :unallocated do
          desc 'Retrieve list of unallocated claims'
          get do
            present claims, with: API::Entities::SearchResult, user: current_user
          end
        end
      end
    end
  end
end
