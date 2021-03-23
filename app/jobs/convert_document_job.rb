class ConvertDocumentJob < ApplicationJob
  queue_as :convert_document

  def perform(id)
    log "Document conversion starting for document id #{id}"

    document = Document.find(id)
    return if document.converted_preview_document.present?

    if document.document.content_type == 'application/pdf'
      copy_file document
    else
      convert_file document
    end
    document.save
  end

  private

  def copy_file(document)
    log 'Copying original PDF file to converted preview document'
    document.converted_preview_document = document.document
    document.as_converted_preview_document_checksum = document.as_document_checksum
  end

  def convert_file(document)
    log 'Converting original file to PDF for converted preview document'
    File.open("#{Dir.mktmpdir}/#{document.document_file_name}.pdf", 'wb+') do |file|
      Libreconv.convert(Paperclip.io_adapters.for(document.document).path, file)
      document.converted_preview_document = file
    end
    document.add_checksum(:converted_preview_document)
  end

  def log(message, level: :info, action: nil)
    LogStuff.send(level, class: self.class.name, action: (action || caller_locations(1..1).first.label)) { message }
  end
end
