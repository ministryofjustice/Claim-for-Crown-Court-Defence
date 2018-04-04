class OffenceBand < ActiveRecord::Base
  belongs_to :offence_category
  has_many :offences
end
