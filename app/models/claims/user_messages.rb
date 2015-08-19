module Claims::UserMessages
  def read_messages
    user_messages_relation.where('user_message_statuses.read = ?', true)
  end

  def unread_messages
    user_messages_relation.where('user_message_statuses.read = ?', false)
  end

  def has_read_messages?
    read_messages.any?
  end

  def has_unread_messages?
    unread_messages.any?
  end

  def has_unread_messages_for?(user)
    unread_messages_for(user).any?
  end

  def has_read_messages_for?(user)
    read_messages_for(user).any?
  end

  def unread_messages_for(user)
    user_messages_relation.where('user_message_statuses.read = ? AND user_message_statuses.user_id = ?', false, user.id)
  end

  def read_messages_for(user)
    user_messages_relation.where('user_message_statuses.read = ? AND user_message_statuses.user_id = ?', true, user.id)
  end

  private

  def user_messages_relation
    messages.joins(:user_message_statuses)
  end
end
