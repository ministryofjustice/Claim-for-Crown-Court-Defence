class InjectionAttempt < ActiveRecord::Base
  belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id

  validates :claim, presence: true
end
