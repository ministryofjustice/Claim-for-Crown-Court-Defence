class ConvertDocumentJob < ApplicationJob
  queue_as :convert_document

  def perform(document_id)
    document = Document.find(document_id)
    DocumentConverterService.new(document.document, document.converted_preview_document).call
    document.populate_paperclip_for :converted_preview_document
    document.save
  end
end
