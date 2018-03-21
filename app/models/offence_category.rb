class OffenceCategory < ActiveRecord::Base
  has_many :offence_bands
end
