module API
  module Entities
    module CCLF
      class CaseType < API::Entities::BaseEntity
        expose :adapted_case_type, as: :bill_scenario

        private

        def adapted_case_type
          ::CCLF::CaseTypeAdapter.new(object).bill_scenario
        end
      end
    end
  end
end
