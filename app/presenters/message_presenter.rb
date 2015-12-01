class MessagePresenter < BasePresenter

  presents :message

  def sender_is_a?(klass)
    message.sender.persona.is_a?(klass)
  end

  def sender_name
    message.sender.name
  end

  def sender_persona
    message.sender.persona.class.to_s.humanize
  end

  def timestamp
    message.created_at.strftime('%H:%M')
  end

end
