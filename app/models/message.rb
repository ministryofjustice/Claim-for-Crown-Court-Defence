# == Schema Information
#
# Table name: messages
#
#  id                      :integer          not null, primary key
#  subject                 :string(255)
#  body                    :text
#  claim_id                :integer
#  sender_id               :integer
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#

class Message < ActiveRecord::Base
  belongs_to :claim
  belongs_to :sender, foreign_key: :sender_id, class_name: 'User', inverse_of: :messages_sent
  has_many :user_message_statuses, dependent: :destroy

  has_attached_file :attachment,
    { s3_headers: {
      'x-amz-meta-Cache-Control' => 'no-cache',
      'Expires' => 3.months.from_now.httpdate
    },
    s3_permissions: :private,
    s3_region: 'eu-west-1'}.merge(PAPERCLIP_STORAGE_OPTIONS)

    validates_attachment :attachment,
      content_type: {
        content_type: ['application/pdf',
                       'application/msword',
                       'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                       'application/vnd.oasis.opendocument.text',
                       'text/rtf',
                       'application/rtf',
                       'image/png']}

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
    users_for_statuses.each do |user|
      UserMessageStatus.create!(user_id: user.id, message_id: self.id, read: user == sender)
    end
  end

  def users_for_statuses
    self.claim.advocate.chamber.advocates.map(&:user) + self.claim.case_workers.map(&:user)
  end
end
