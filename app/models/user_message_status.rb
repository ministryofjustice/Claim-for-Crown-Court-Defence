class UserMessageStatus < ActiveRecord::Base
  belongs_to :user
  belongs_to :message

  validates :user, :message, presence: true
end
