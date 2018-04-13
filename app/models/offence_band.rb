class OffenceBand < ApplicationRecord
  belongs_to :offence_category
  has_many :offences
end
