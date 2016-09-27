module API
  module V2
    module CaseWorkers
      class Claim < Grape::API
        namespace :case_workers do
          resource :claims, desc: 'Operations on allocated claims' do

            # TODO: To be implemented
            desc 'Retrieve allocated claims'
            get do
              {text: 'Hello from V2::CaseWorkers::Claim'}
            end

          end
        end
      end
    end
  end
end
