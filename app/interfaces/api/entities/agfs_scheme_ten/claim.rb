module API
  module Entities
    module AGFSSchemeTen
      class Claim < BaseEntity
        expose :defendant
        expose :case_number
        expose :case_type
        expose :court
        expose :offence
        expose :offence_band
        expose :provider_name
        expose :user_name
        expose :representation_order_date
      end
    end
  end
end
