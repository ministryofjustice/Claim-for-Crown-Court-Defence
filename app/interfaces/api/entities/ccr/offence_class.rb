module API
  module Entities
    module CCR
      class OffenceClass < API::Entities::BaseEntity
        # CCR class letters map accurately one-to-one with CCCD class letters
        expose :class_letter
      end
    end
  end
end
