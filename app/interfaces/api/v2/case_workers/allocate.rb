module API
  module V2
    module CaseWorkers
      class Allocate < Grape::API
        namespace :case_workers do
          params do
            optional :api_key, type: String, desc: I18n.t('api.v2.generic.params.api_key')
            requires :case_worker_id, type: Integer, desc: I18n.t('api.v2.allocate.params.case_worker_id')
            optional :claim_ids,
                     type: Array[Integer],
                     desc: I18n.t('api.v2.allocate.params.claim_ids'),
                     coerce_with: ->(val) { val.split(/[,]/).map(&:to_i) }
          end

          resource :allocate, desc: 'Allocate claims' do
            helpers do
              def allocation_params
                params.except(:api_key).merge(current_user: current_user, allocating: true)
              end
            end
            desc 'Allocate claims to case workers'
            post do
              @allocation = Allocation.new(allocation_params)

              result = @allocation.save
              status 422 if result.eql?(false)

              {
                result: result,
                allocated_claims: @allocation.successful_claims.map(&:id),
                errors: @allocation.errors[:base]
              }
            end
          end
        end
      end
    end
  end
end
