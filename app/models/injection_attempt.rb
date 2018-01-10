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
  include ActiveModel::AttributeMethods

  belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id

  validates :claim, presence: true

  def failed?
    !succeeded
  end

  def real_error_messages
    read_attribute(:error_messages)&.with_indifferent_access
  end

  def error_messages
    data = real_error_messages
    messages = data&.fetch(:errors)&.map { |child| child[:error] }
    messages || []
  end
end
