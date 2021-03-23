module DocumentAttachment
  extend ActiveSupport::Concern
  include S3Headers

  included do
    attr_accessor :pdf_tmpfile

    has_attached_file :converted_preview_document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)

    has_attached_file :document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)

    validates_attachment_content_type :converted_preview_document, content_type: 'application/pdf'
  end
end
