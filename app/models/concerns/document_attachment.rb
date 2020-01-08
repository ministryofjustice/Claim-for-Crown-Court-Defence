module DocumentAttachment
  extend ActiveSupport::Concern
  include S3Headers

  included do
    attr_accessor :pdf_tmpfile, :active_storage_pdf_tmpfile

    has_one_attached :active_storage_document

    has_one_attached :active_storage_converted_preview_document

    has_attached_file :converted_preview_document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)

    has_attached_file :document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)

    validates_attachment_content_type :converted_preview_document, content_type: 'application/pdf'
  end

  def generate_pdf_tmpfile
    if File.extname(document_file_name).casecmp('.pdf').zero?
      self.pdf_tmpfile = document # if original document is PDF, make tmpfile from original doc
    else
      convert_and_assign_document
    end
  end

  def generate_active_storage_pdf_tmpfile
    if File.extname(active_storage_document.filename.to_s).casecmp('.pdf').zero?
      self.active_storage_pdf_tmpfile = active_storage_document # if original document is PDF, make tmpfile from original doc
    else
      active_storage_convert_and_assign_document
    end
  end

  def convert_and_assign_document
    # Libreconvert performs both actions in one call
    self.pdf_tmpfile = File.new("#{Dir.mktmpdir}/#{document_file_name}.pdf", 'wb+')
    Libreconv.convert(Paperclip.io_adapters.for(document).path, pdf_tmpfile) # Libreoffice exe must be in PATH
  rescue IOError
    nil # raised if Libreoffice exe is not in PATH
  end

  def active_storage_convert_and_assign_document
    # Libreconvert performs both actions in one call
    self.active_storage_pdf_tmpfile = File.new("#{Dir.mktmpdir}/#{active_storage_document.filename}.pdf", 'wb+')
    Libreconv.convert(ActiveStorage::Blob.service.send(:path_for, active_storage_document.key), active_storage_pdf_tmpfile) # Libreoffice exe must be in PATH
  rescue IOError
    nil # raised if Libreoffice exe is not in PATH
  end

  def add_converted_preview_document
    self.converted_preview_document = pdf_tmpfile if converted_preview_document_file_name.nil?
  end

  def add_active_storage_converted_preview_document
    return if active_storage_converted_preview_document.attached?
    if active_storage_pdf_tmpfile.class < ActiveStorage::Attached
      active_storage_converted_preview_document.attach(
        active_storage_pdf_tmpfile.blob
      )
    else
      active_storage_converted_preview_document.attach(
        io: File.open(active_storage_pdf_tmpfile.path),
        filename: File.basename(active_storage_pdf_tmpfile),
        content_type: 'application/pdf'
      )
    end
  end
end
