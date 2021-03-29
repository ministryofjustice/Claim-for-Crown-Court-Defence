module PaperclipRollback
  def populate_paperclip_for(attachment_name)
    attachment = send(attachment_name)
    return unless attachment.attached?

    send("#{attachment_name}_file_name=", attachment.filename)
    send("#{attachment_name}_file_size=", attachment.byte_size)
    send("#{attachment_name}_content_type=", attachment.content_type)
    send("#{attachment_name}_updated_at=", Time.zone.now)
    send("as_#{attachment_name}_checksum=", attachment.checksum)
  end
end
