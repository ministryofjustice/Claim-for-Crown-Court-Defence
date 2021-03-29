module DocumentAttachment
  extend ActiveSupport::Concern

  private

  def convert_document from:, to:
    return if to.attached?

    if from.content_type == 'application/pdf'
      to.attach(from.blob)
    else
      convert_document_to_pdf from: from, to: to
    end
  end

  def convert_document_to_pdf from:, to:
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

    original = from.record.attachment_changes['document'].attachable.tempfile.path
    pdf_tmpfile = Tempfile.new
    Libreconv.convert(original, pdf_tmpfile)
    to.attach(
      io: pdf_tmpfile,
      filename: "#{from.filename}.pdf",
      content_type: 'application/pdf'
    )
  rescue IOError
    nil # raised if Libreoffice exe is not in PATH
  end
end
