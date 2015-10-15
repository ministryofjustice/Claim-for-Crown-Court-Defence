# == Schema Information
#
# Table name: claim_intentions
#
#  id         :integer          not null, primary key
#  form_id    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ClaimIntention < ActiveRecord::Base
  validates :form_id, presence: true, uniqueness: true
end
