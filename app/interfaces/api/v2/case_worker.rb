module API
  module V2
    class CaseWorker < Grape::API
      helpers API::V2::CriteriaHelper

      helpers do
        def active_case_workers
          ::CaseWorker.active.includes(:user).order(sorting)
        end
      end

      resource :case_workers, desc: 'Operations on case workers' do
        desc 'Retrieve a list of case workers'
        params do
          optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the user'
          use :sorting
        end
        get do
          present active_case_workers, with: API::Entities::CaseWorker
        end
      end
    end
  end
end
