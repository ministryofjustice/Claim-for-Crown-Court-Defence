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
  has_many :user_message_statuses, dependent: :destroy

  validates :subject, :body, :sender_id, :claim_id, presence: true

  scope :most_recent_first, -> { includes(:user_message_statuses).order(created_at: :desc) }

  after_create :generate_statuses

  class << self
    def for(object)
      attribute = case object.class.to_s
        when 'Claim'
          :claim_id
        when 'User'
          :sender_id
      end
      where(attribute => object.id)
    end
  end

  private

  def generate_statuses
    users = [self.claim.advocate.user] + self.claim.case_workers.map(&:user)
    users.each do |user|
      UserMessageStatus.create!(user_id: user.id, message_id: self.id)
    end
  end
end
