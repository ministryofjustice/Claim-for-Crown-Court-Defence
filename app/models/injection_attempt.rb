# == Schema Information
#
# Table name: injection_attempts
#
#  id             :integer          not null, primary key
#  claim_id       :integer
#  succeeded      :boolean
#  created_at     :datetime
#  updated_at     :datetime
#  error_messages :json
#  deleted_at     :datetime
#

class InjectionAttempt < ApplicationRecord
  include SoftlyDeletable
  include JsonAttrParser

  scope :exclude_error, ->(error_ilike) { where.not('coalesce(error_messages::text,\'\') ILIKE ?', error_ilike) }

  belongs_to :claim, class_name: 'Claim::BaseClaim'

  validates :claim, presence: true

  def real_error_messages
    self[:error_messages]&.with_indifferent_access
  end

  def error_messages
    data = real_error_messages
    messages = data&.fetch(:errors)&.pluck(:error)
    messages || []
  end

  def notification_can_be_skipped?
    succeeded? || error_messages.any? { |message| message.include?('already exist') }
  end
end
