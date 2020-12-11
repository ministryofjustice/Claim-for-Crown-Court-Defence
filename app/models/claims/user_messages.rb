module Claims::UserMessages
  def has_unread_messages_for?(user)
    unread_messages_for(user).any?
  end

  def unread_messages_for(user)
    user_messages_relation.where('user_message_statuses.read = ? AND user_message_statuses.user_id = ?', false, user.id)
  end

  private

  def user_messages_relation
    messages.joins(:user_message_statuses)
  end
end
