class UserMessageStatus < ActiveRecord::Base
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
