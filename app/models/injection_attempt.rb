# == Schema Information
#
# Table name: injection_attempts
#
#  id            :integer          not null, primary key
#  claim_id      :integer
#  succeeded     :boolean
#  error_message :string
#  created_at    :datetime
#  updated_at    :datetime
#

class InjectionAttempt < ActiveRecord::Base
  belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id

  scope :errored, -> { where.not(succeeded: true).order(created_at: :asc) }

  validates :claim, presence: true
end
