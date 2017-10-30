module API
  module V2
    module CaseWorkers
      class Claim < Grape::API
        helpers API::V2::CriteriaHelper

        namespace :case_workers do
          params do
            optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
            optional  :status,
                      type: String,
                      default: 'current',
                      values: %w[current allocated unallocated archived],
                      desc: 'REQUIRED: Only returns claims in the specified status'
            optional  :scheme,
                      type: String,
                      default: 'agfs',
                      values: %w[agfs lgfs],
                      desc: 'OPTIONAL: This will be used to filter the list of allocated/unallocated claims'
            optional  :filter,
                      type: String,
                      default: 'all',
                      values: %w[all redetermination awaiting_written_reasons fixed_fee cracked trial guilty_plea graduated_fees interim_fees warrants interim_disbursements risk_based_bills],
                      desc: 'OPTIONAL: Filter unallocated claims. Some filters only apply to AGFS or LGFS schemas.'
            use :searching
            use :sorting
            use :pagination
          end

          helpers do
            def search_options
              options = %i[case_number maat_reference defendant_name]
              options << :case_worker_name_or_email if current_user.persona.admin?
              options
            end

            def search_terms
              params.search.to_s.strip
            end

            def scheme
              params.scheme
            end

            def filter
              params.filter
            end

            def value_band_id
              params.value_band_id
            end

            def current_claims
              current_user.claims.caseworker_dashboard_under_assessment.search(
                search_terms, Claims::StateMachine::CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES, *search_options
              )
            end

            def archived_claims
              ::Claim::BaseClaim.active.caseworker_dashboard_archived.search(
                search_terms, Claims::StateMachine::CASEWORKER_DASHBOARD_ARCHIVED_STATES, *search_options
              )
            end

            def allocated_claims
              ::Claim::BaseClaim.active.__send__(scheme).caseworker_dashboard_under_assessment.search(
                search_terms, Claims::StateMachine::CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES, *search_options
              )
            end

            def unallocated_claims
              ::Claim::BaseClaim
                .active.__send__(scheme)
                .submitted_or_redetermination_or_awaiting_written_reasons
                .filter(filter)
                .value_band(value_band_id)
            end

            def claims_scope
              send("#{params.status}_claims")
            end

            def claims
              claims_scope.sort(params.sorting, params.direction).page(params.page).per(params.limit)
            end
          end

          resource :claims do
            desc 'Retrieve list of allocated, unallocated or archived claims'
            get do
              present claims, with: API::Entities::PaginatedCollection, user: current_user
            end
          end
        end
      end
    end
  end
end
