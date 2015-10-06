class ClaimIntention < ActiveRecord::Base
  validates :form_id, presence: true, uniqueness: true
end
