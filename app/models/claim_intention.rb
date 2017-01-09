# == Schema Information
#
# Table name: claim_intentions
#
#  id         :integer          not null, primary key
#  form_id    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class ClaimIntention < ActiveRecord::Base
  validates :form_id, presence: true, uniqueness: {message: 'There is already a claim with this form-id'}

  belongs_to :user
end
