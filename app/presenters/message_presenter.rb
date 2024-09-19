class MessagePresenter < BasePresenter
  presents :message

  def sender_is_a?(klass)
    message.sender.persona.is_a?(klass)
  end

  def sender_name
    return '(Case worker)' if sender_is_a?(CaseWorker) && hide_author?
    message.sender.name
  end

  def timestamp
    message.created_at.strftime('%H:%M')
  end

  private

  def hide_author?
    h.current_user_is_external_user?
  end
end
