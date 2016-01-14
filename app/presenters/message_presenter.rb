class MessagePresenter < BasePresenter

  presents :message

  def sender_is_a?(klass)
    message.sender.persona.is_a?(klass)
  end

  def body
    h.content_tag :div do
      h.concat(h.content_tag :div, message.body)
      if message.attachment.present?
        attachment_field
      end
    end
  end

  def attachment_field
    h.concat("Attachment: ")
    download_file_link
  end

  def download_file_link
    h.concat(
      h.content_tag :a, "#{message.attachment.original_filename}",
      href: "/messages/#{message.id}/download_attachment",
      title: 'Download '+ message.attachment.original_filename
    )
  end

  def sender_name
    message.sender.name
  end

  def sender_persona
    case message.sender.persona
      when CaseWorker
        'Caseworker'
      when ExternalUser
        'Advocate'
    end
  end

  def timestamp
    message.created_at.strftime('%H:%M')
  end

end
