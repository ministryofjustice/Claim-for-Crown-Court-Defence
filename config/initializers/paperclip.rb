require 'active_storage/service/s3_service'

Paperclip.interpolates :active_storage_path do |attachment, style|
  record = attachment.instance
  default = record.instance_of?(Stats::StatsReport) ? REPORTS_STORAGE_PATH : PAPERCLIP_STORAGE_PATH

  active_storage_attachment = ActiveStorage::Attachment.find_by(
    record_type: record.class.name,
    record_id: record.id,
    name: attachment.name
  )
  return interpolate(default, attachment, style) unless active_storage_attachment&.key&.exclude?('/')
  return active_storage_attachment.key if ActiveStorage::Blob.service.is_a? ActiveStorage::Service::S3Service

  ActiveStorage::Blob.service.path_for(active_storage_attachment.key)
end
