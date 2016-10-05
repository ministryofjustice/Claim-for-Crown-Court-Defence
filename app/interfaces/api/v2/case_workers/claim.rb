module API
  module V2
    module CaseWorkers
      class Claim < Grape::API
        helpers API::V2::CriteriaHelper

        namespace :case_workers do
          params do
            optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
            optional :status, type: String, values: %w(allocated archived), default: 'allocated', desc: 'REQUIRED: Returns allocated claims or archived claims'
            use :searching
            use :sorting
            use :pagination
          end

          helpers do
            def search_options
              options = [:case_number, :maat_reference, :defendant_name]
              options << :case_worker_name_or_email if current_user.persona.admin?
              options
            end

            def search_terms
              params.search.to_s.strip
            end

            def allocated_claims
              current_user.claims.caseworker_dashboard_under_assessment.search(
                  search_terms, Claims::StateMachine::CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES, *search_options)
            end

            def archived_claims
              ::Claim::BaseClaim.active.caseworker_dashboard_archived.search(
                  search_terms, Claims::StateMachine::CASEWORKER_DASHBOARD_ARCHIVED_STATES, *search_options)
            end

            def claims
              claims_scope = params.status == 'allocated' ? allocated_claims : archived_claims
              claims_scope.sort(params.sorting, params.direction).page(params.page).per(params.limit)
            end
          end

          after do
            header 'Cache-Control', 'max-age=15'
          end

          resource :claims, desc: 'Operations on allocated claims' do
            desc 'Retrieve list of allocated or archived claims'
            get do
              present claims, with: API::Entities::PaginatedCollection, user: current_user
            end
          end
        end
      end
    end
  end
end
