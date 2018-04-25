class OffenceFeeScheme < ApplicationRecord
  belongs_to :offence
  belongs_to :fee_scheme
end
