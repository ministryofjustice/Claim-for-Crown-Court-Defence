module API
  module Entities
    module CCR
      class CaseType < API::Entities::CCR::BaseEntity
        # INJECTION: bill scenario is a CCCD mapping to CCR data based on case type description
        # which should, ideally, be replaced by a uuid which is mapped CCR-side
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
