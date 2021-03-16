module PaperclipPath
  def paperclip_path(name:, default:)
    active_storage_attachment = ActiveStorage::Attachment.find_by(
      record_type: self.class.name,
      record_id: id,
      name: name
    )
    if active_storage_attachment&.key&.exclude?('/')
      ActiveStorage::Blob.service.path_for(active_storage_attachment.key)
    else
      default
    end
  end
end
