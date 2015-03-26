class ClaimFee < ActiveRecord::Base
  belongs_to :claim
  belongs_to :fee
end
