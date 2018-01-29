module API
  module Entities
    module CCR
      class CaseType < API::Entities::BaseEntity
        expose :adapted_case_type, as: :bill_scenario

        # INJECTION: the case type UUID should, ideally, be used CCR-side to map to a bill scenario
        expose :uuid

        private

        def adapted_case_type
          ::CCR::CaseTypeAdapter.new(object).bill_scenario
        end
      end
    end
  end
end
