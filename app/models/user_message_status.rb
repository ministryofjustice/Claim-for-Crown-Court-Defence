# == Schema Information
#
# Table name: user_message_statuses
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  message_id :integer
#  read       :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class UserMessageStatus < ApplicationRecord
  belongs_to :user
  belongs_to :message

  validates :user, :message, presence: true

  scope :marked_as_read, -> { where(read: true) }
  scope :not_marked_as_read, -> { where(read: false) }

  class << self
    def for(user)
      where(user_id: user.id)
    end
  end
end
