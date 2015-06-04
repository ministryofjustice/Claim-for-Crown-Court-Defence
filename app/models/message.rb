# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  subject    :string(255)
#  body       :text
#  claim_id   :integer
#  sender_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Message < ActiveRecord::Base
  belongs_to :claim
  belongs_to :sender, foreign_key: :sender_id, class_name: 'User', inverse_of: :messages_sent

  validates :subject, :body, :sender_id, :claim_id, presence: true

  scope :most_recent_first, -> { order(created_at: :desc) }
end
