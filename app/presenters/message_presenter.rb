class MessagePresenter < BasePresenter

  presents :message

  def sender_is_a?(klass)
    message.sender.persona.is_a?(klass)
  end

  def body
    h.content_tag :div do
      h.concat(h.content_tag :div, message.body)
      if message.attachment.present?
        h.concat("Attachment: ")
        h.concat(
          h.content_tag :a, "#{message.attachment.original_filename}",
          href: "/messages/#{message.id}/download_attachment",
          title: 'Download '+ message.attachment.original_filename
        )
      end
    end
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
