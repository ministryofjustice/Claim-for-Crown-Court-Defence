module API
  module Entities
    class Totals < BaseEntity
      with_options(format_with: :decimal) do
        expose :fees_total, as: :fees
        expose :expenses_total, as: :expenses
        expose :disbursements_total, as: :disbursements
        expose :vat_amount
        expose :total
      end
    end
  end
end
