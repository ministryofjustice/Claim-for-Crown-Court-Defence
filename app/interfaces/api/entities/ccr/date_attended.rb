module API
  module Entities
    module CCR
      class DateAttended < BaseEntity
        expose :date, as: :from, format_with: :utc
        expose :date_to, as: :to, format_with: :utc
      end
    end
  end
end
