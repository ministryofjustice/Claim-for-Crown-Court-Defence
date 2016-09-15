class MessagePresenter < BasePresenter

  presents :message

  def sender_is_a?(klass)
    message.sender.persona.is_a?(klass)
  end

  def body
    h.content_tag :div do
      h.concat(simple_format(message.body))
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
      h.content_tag(
        :a, "#{attachment_file_name} (#{attachment_file_size})",
        href: "/messages/#{message.id}/download_attachment",
        title: 'Download ' + attachment_file_name
      )
    )
  end

  def attachment_file_name
    message.attachment.original_filename
  end

  def attachment_file_size
    h.number_to_human_size(message.attachment_file_size)
  end

  def sender_name
    return '(Case worker)' if sender_is_a?(CaseWorker) && hide_author?
    message.sender.name
  end

  def timestamp
    message.created_at.strftime('%H:%M')
  end

  def hide_author?
    h.current_user_is_external_user?
  end
end
