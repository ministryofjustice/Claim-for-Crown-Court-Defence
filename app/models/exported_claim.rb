# == Schema Information
#
# Table name: exported_claims
#
#  id           :integer          not null, primary key
#  claim_id     :integer          not null
#  claim_uuid   :uuid             not null
#  status       :string
#  status_code  :integer
#  status_msg   :string
#  retries      :integer          default(0), not null
#  created_at   :datetime
#  updated_at   :datetime
#  published_at :datetime
#  retried_at   :datetime
#

class ExportedClaim < ActiveRecord::Base

  belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id

  # TODO: we need to decide what a 'successful' (not pending) claim means
  scope :pending, -> { where(status: 'published') }

  def published?
    self.status == 'published'
  end
end
