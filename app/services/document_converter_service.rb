class DocumentConverterService
  def initialize(original)
    @original = original
  end

  def to(converted)
    return if converted.attached?

    if @original.content_type == 'application/pdf'
      converted.attach(@original.blob)
    else
      convert_document_to_pdf from: @original, to: converted
    end
  end

  private

  def convert_document_to_pdf(from:, to:)
    with_attached_file(from) do |original|
      pdf_tmpfile = Tempfile.new
      Libreconv.convert(original, pdf_tmpfile)
      to.attach(io: pdf_tmpfile, filename: "#{from.filename}.pdf", content_type: 'application/pdf')
    end
  rescue IOError
    nil # raised if Libreoffice exe is not in PATH
  end

  def with_attached_file(document)
    # Currently, evidence documents are converted to PDF when the document is
    # uploaded and before the instance of Document is saved. This is how it
    # was done with Paperclip but with Active the file is not accessible at
    # until it is saved. This is why the path is taken as the temporary file
    # of the attachment.
    if document.new_record?
      yield(document.record.attachment_changes[document.name].attachable.tempfile.path)
    else
      document.open do |file|
        yield(file.path)
      end
    end
  end
end
