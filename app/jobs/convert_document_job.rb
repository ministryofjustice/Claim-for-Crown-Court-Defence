class ConvertDocumentJob < ApplicationJob
  queue_as :convert_document

  def perform(document_id)
    document = Document.find_by(id: document_id)
    return if document.nil?

    DocumentConverterService.new(document.document, document.converted_preview_document).call
  end
end
