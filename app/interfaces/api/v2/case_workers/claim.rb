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
                      values: %w[all redetermination awaiting_written_reasons fixed_fee cracked trial guilty_plea
                                 graduated_fees interim_fees warrants interim_disbursements risk_based_bills],
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
              return if params[:params] == 'unallocated'

              params[:search].to_s.strip
            end

            def scheme
              params[:scheme]
            end

            def filter
              params[:filter]
            end

            def value_band_id
              params[:value_band_id]
            end

            def current_claims
              current_user.claims.where(id: generic_claims)
            end

            def archived_claims
              generic_claims
            end

            def allocated_claims
              generic_claims.public_send(scheme)
            end

            def generic_claims
              ClaimSearchService.call(
                state: states_for_status,
                term: search_terms,
                user: current_user.persona
              )
            end

            def states_for_status
              case params[:status]
              when 'allocated'
                Claims::StateMachine::CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES
              when 'current', 'archived'
                Claims::StateMachine::CASEWORKER_DASHBOARD_ARCHIVED_STATES
              when 'unallocated'
                Claims::StateMachine::CASEWORKER_DASHBOARD_UNALLOCATED_STATES
              end
            end

            def unallocated_claims
              generic_claims
                .__send__(scheme)
                .filter_by(filter)
                .value_band(value_band_id)
            end

            def claims_scope
              send("#{params[:status]}_claims")
            end

            def claims
              claims_scope
                .includes(:external_user, :case_type, :injection_attempts,
                          :case_workers, :court, :messages,
                          defendants: %i[representation_orders])
                .sort_using(params[:sorting], params[:direction])
                .page(params[:page]).per(params[:limit])
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
