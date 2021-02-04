module DocumentAttachment
  extend ActiveSupport::Concern
  include S3Headers

  included do
    attr_accessor :pdf_tmpfile

    has_one_attached :converted_preview_document
    has_one_attached :document

    before_save :create_preview_document

    validates :converted_preview_document, content_type: 'application/pdf'
    validates :document,
              presence: true,
              size: { less_than: 20.megabytes },
              content_type: [
                'application/pdf',
                'application/msword',
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                'application/vnd.oasis.opendocument.text',
                'text/rtf',
                'application/rtf',
                'image/jpeg',
                'image/png',
                'image/tiff',
                'image/bmp',
                'image/x-bitmap'
              ]
  end

  def create_preview_document
    if document.content_type == 'application/pdf'
      self.converted_preview_document = document.blob
    else
      convert_document_to_pdf
    end
  end

  private

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
end
