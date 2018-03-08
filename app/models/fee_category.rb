class FeeCategory < ActiveRecord::Base
  has_many :fee_bands
end
