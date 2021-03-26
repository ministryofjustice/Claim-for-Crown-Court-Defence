module DocumentAttachment
  extend ActiveSupport::Concern
  include S3Headers

  included do
    attr_accessor :pdf_tmpfile

    has_one_attached :converted_preview_document
    has_one_attached :document

    before_save :create_preview_document
    before_save :populate_paperclip_for_document
    before_save :populate_paperclip_for_converted_preview_document

    validates :converted_preview_document, content_type: 'application/pdf'
    validates :document,
              presence: true,
              size: { less_than: 20.megabytes },
              content_type: %w[
                application/pdf
                application/msword
                application/vnd.openxmlformats-officedocument.wordprocessingml.document
                application/vnd.oasis.opendocument.text
                text/rtf
                application/rtf
                image/jpeg
                image/png
                image/tiff
                image/bmp
                image/x-bitmap
              ]
  end

  private

  def create_preview_document
    return if converted_preview_document.attached?

    if document.content_type == 'application/pdf'
      converted_preview_document.attach(document.blob)
    else
      convert_document_to_pdf
    end
  end

  def convert_document_to_pdf
    # This is an attempt to recreate how the preview PDF was created with
    # Paperclip. However, it is accessing the original file in an
    # undocumented way and so may change with future versions of Rails. It
    # is done in this way because the file is not accessible to Active
    # Storage until after the `save` but this conversion is being done
    # before.
    #
    # Possible alternatives are:
    #
    # 1) Convert the file in a background job.
    # 2) Use the built-in Active Storage Previewer functionality, although
    #    this may not behave in exactly the same way.
    #
    # Either of these would have the advantage of reducing the response time
    # when a new file is added.

    original = document.record.attachment_changes['document'].attachable.tempfile.path
    pdf_tmpfile = Tempfile.new
    Libreconv.convert(original, pdf_tmpfile)
    converted_preview_document.attach(
      io: pdf_tmpfile,
      filename: "#{document.filename}.pdf",
      content_type: 'application/pdf'
    )
  rescue IOError
    nil # raised if Libreoffice exe is not in PATH
  end

  def populate_paperclip_for_document
    self.document_file_name = document.filename
    self.document_file_size = document.byte_size
    self.document_content_type = document.content_type
    self.document_updated_at = Time.zone.now
    self.as_document_checksum = document.checksum
  end

  # High ABC Size due to setting Paperclip fields for possible revert.
  # This 'rubocop:disable' can be removed when the Paperclip fields are removed.
  # rubocop:disable Metrics/AbcSize
  def populate_paperclip_for_converted_preview_document
    return unless converted_preview_document.attached?

    self.converted_preview_document_file_name = converted_preview_document.filename
    self.converted_preview_document_file_size = converted_preview_document.byte_size
    self.converted_preview_document_content_type = converted_preview_document.content_type
    self.converted_preview_document_updated_at = Time.zone.now
    self.as_converted_preview_document_checksum = converted_preview_document.checksum
  end
  # rubocop:enable Metrics/AbcSize
end
