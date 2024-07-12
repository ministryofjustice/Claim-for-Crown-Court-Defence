class MessagePresenter < BasePresenter
  presents :message

  def sender_is_a?(klass)
    message.sender.persona.is_a?(klass)
  end

  def body
    h.tag.div do
      h.concat(simple_format(message.body))
      attachment_field if message.attachment.first.present?
    end
  end

  def sender_name
    return '(Case worker)' if sender_is_a?(CaseWorker) && hide_author?
    message.sender.name
  end

  def timestamp
    message.created_at.strftime('%H:%M')
  end

  private

  def attachment_field
    h.concat('Attachment: ')
    download_file_link
  end

  def download_file_link
    h.concat(
      h.tag.a(
        "#{attachment_file_name} (#{attachment_file_size})",
        href: "/messages/#{message.id}/download_attachment",
        title: 'Download ' + attachment_file_name
      )
    )
  end

  def attachment_file_name
    message.attachment.first.filename.to_s
  end

  def attachment_file_size
    h.number_to_human_size(message.attachment.first.byte_size)
  end

  def hide_author?
    h.current_user_is_external_user?
  end
end
