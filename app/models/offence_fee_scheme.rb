class OffenceFeeScheme < ActiveRecord::Base
  belongs_to :offence
  belongs_to :fee_scheme
end
