module PaperclipPath
  def paperclip_path(name:, default:)
    active_storage_attachment = ActiveStorage::Attachment.find_by(
      record_type: self.class.name,
      record_id: id, name: name
    )
    return default unless active_storage_attachment&.key&.exclude?('/')
    return active_storage_attachment.key if ActiveStorage::Blob.service.is_a? ActiveStorage::Service::S3Service

    ActiveStorage::Blob.service.path_for(active_storage_attachment.key)
  end
end
