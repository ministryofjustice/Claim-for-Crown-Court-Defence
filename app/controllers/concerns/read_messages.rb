module ReadMessages
  extend ActiveSupport::Concern

  included do
    after_action :mark_messages_read, only: [:show]
  end

  private

  def mark_messages_read
    statuses = current_user.user_message_statuses.not_marked_as_read.where(message_id: @claim.messages.map(&:id))
    statuses.each { |status| status.update_column(:read, true) }
  end
end
