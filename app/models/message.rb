# == Schema Information
#
# Table name: messages
#
#  id                      :integer          not null, primary key
#  body                    :text
#  claim_id                :integer
#  sender_id               :integer
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#

class Message < ApplicationRecord
  belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id
  belongs_to :sender, foreign_key: :sender_id, class_name: 'User', inverse_of: :messages_sent
  has_many :user_message_statuses, dependent: :destroy

  attr_accessor :claim_action, :written_reasons_submitted

  has_attached_file :attachment,
                    { s3_headers: {
                      'x-amz-meta-Cache-Control' => 'no-cache',
                      'Expires' => 3.months.from_now.httpdate
                    },
                      s3_permissions: :private,
                      s3_region: 'eu-west-1' }.merge(PAPERCLIP_STORAGE_OPTIONS)

  validates_attachment :attachment,
                       size: { in: 0.megabytes..20.megabytes },
                       content_type: {
                         content_type: ['application/pdf',
                                        'application/msword',
                                        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                                        'application/vnd.oasis.opendocument.text',
                                        'text/rtf',
                                        'application/rtf',
                                        'image/jpeg',
                                        'image/png',
                                        'image/tiff',
                                        'image/bmp',
                                        'image/x-bitmap']
                       }

  validates :sender, presence: { message: 'Message sender cannot be blank' }
  validates :body, presence: { message: 'Message body cannot be blank' }
  validates :claim_id, presence: { message: 'Message claim_id cannot be blank' }

  scope :most_recent_first, -> { includes(:user_message_statuses).order(created_at: :desc) }

  scope :most_recent_last, -> { includes(:user_message_statuses).order(created_at: :asc) }

  after_create :generate_statuses, :process_claim_action, :process_written_reasons

  class << self
    def for(object)
      attribute = case object.class.to_s
                  when 'Claim::AdvocateClaim'
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
      UserMessageStatus.create!(user_id: user.id, message_id: id, read: user == sender)
    end
  end

  def users_for_statuses
    claim.provider.external_users.map(&:user) + claim.case_workers.map(&:user)
  end

  def process_claim_action
    return unless Claims::StateMachine::VALID_STATES_FOR_REDETERMINATION.include?(claim.state)

    case claim_action
    when /Apply for redetermination/
      claim_updater.request_redetermination
    when /Request written reasons/
      claim_updater.request_written_reasons
    end
  end

  def process_written_reasons
    return unless claim.written_reasons_outstanding?
    return unless written_reasons_submitted == '1'
    claim.send("#{claim.filtered_state_transitions.second.event}!", author_id: sender_id)
  end

  def claim_updater
    Claims::ExternalUserClaimUpdater.new(claim, current_user: sender)
  end
end
