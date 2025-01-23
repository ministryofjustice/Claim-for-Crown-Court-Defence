class DocumentConverterService
  def initialize(original, converted)
    @original = original
    @converted = converted
  end

  def call
    return if @converted.attached?

    if @original.content_type == 'application/pdf'
      @converted.attach(@original.blob)
    else
      convert_to_pdf from: @original, to: @converted
    end
  end

  private

  def convert_to_pdf(from:, to:)
    with_attached_file(from) do |original|
      pdf_tmpfile = Tempfile.new
      Libreconv.convert(original, pdf_tmpfile)
      to.attach(io: pdf_tmpfile, filename: "#{from.filename}.pdf", content_type: 'application/pdf')
    end
  rescue IOError => e
    log('Failed to convert document', e)
    raise
  end

  def with_attached_file(document)
    if document.new_record?
      # If an Active Storage document is not yet saved then it is not
      # accessible so the path is taken as the temporary upload location.
      yield(document.record.attachment_changes[document.name].attachable.tempfile.path)
    else
      document.open do |file|
        yield(file.path)
      end
    end
  end

  def log(message, error, action: nil)
    LogStuff.warn(
      class: self.class.name,
      action: action || caller(1..1).first[/'.*'/][1..-2],
      error: "#{error.class}: #{error.message}",
      original: @original.to_param,
      converted: @converted.to_param
    ) { message }
  end
end
