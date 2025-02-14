class MessagePresenter < BasePresenter
  presents :message

  def sender_is_a?(klass)
    message.sender.persona.is_a?(klass)
  end

  def body
    h.tag.div do
      h.concat(simple_format(message.body))
      attachment_field if message.attachments.present?
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
    h.concat('Attachments: ')
    message.attachments.each do |attachment|
      h.concat(h.tag.br)
      download_file_link(attachment)
    end
  end

  def download_file_link(attachment)
    h.concat(
      h.tag.a(
        "#{attachment_file_name(attachment)} (#{attachment_file_size(attachment)})",
        href: "/messages/#{message.id}/download_attachment?attachment_id=#{attachment.id}",
        title: 'Download ' + attachment_file_name(attachment)
      )
    )
  end

  def attachment_file_name(attachment)
    attachment.filename.to_s
  end

  def attachment_file_size(attachment)
    h.number_to_human_size(attachment.byte_size)
  end

  def hide_author?
    h.current_user_is_external_user?
  end
end
