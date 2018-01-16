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

class InjectionAttempt < ActiveRecord::Base
  include SoftlyDeletable

  belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id

  validates :claim, presence: true

  def real_error_messages
    read_attribute(:error_messages)&.with_indifferent_access
  end

  def error_messages
    data = real_error_messages
    messages = data&.fetch(:errors)&.map { |child| child[:error] }
    messages || []
  end
end
