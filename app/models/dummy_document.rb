# DummyDocument: class used to shadow a real
# Document for dummy paperclip s3 file creation.
#
# The "Shadow" Document object does not include callbacks
# that would otherwise generate a pdf from the original file
# when it has changed and is saved. This would take a long time and
# not needed for dummy s3 file creation
#
# It also prevents validation of the file content and type so
# random bytes can be used to quickly create the dummy file content
#
class DummyDocument < ApplicationRecord
  include S3Headers
  include CheckSummable

  self.table_name = 'documents'
  has_attached_file :converted_preview_document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)
  has_attached_file :document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)

  do_not_validate_attachment_file_type :document
end
