module API
  module Entities
    module CCLF
      class AdaptedBaseBill < API::Entities::BaseEntity
        expose :bill_type
        expose :bill_subtype
        expose :vat_included
      end
    end
  end
end
