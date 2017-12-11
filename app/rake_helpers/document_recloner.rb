class DocumentRecloner
  def initialize(claim_id)
    @cloned_claim = Claim::BaseClaim.active.find claim_id
    @source_claim = Claim::BaseClaim.active.find @cloned_claim.clone_source_id
    @message_text = 'SYSTEM NOTICE: '
    @sender = CaseWorker.active.admins.first.user
  end

  def run
    remove_corrupted_documents_from_clone
    copy_documents_from_source_claim
    update_messages
  end

  private

  def update_messages
    Message.create(claim_id: @cloned_claim.id, body: @message_text.chomp, sender: @sender)
  end

  def remove_corrupted_documents_from_clone
    @cloned_claim.documents.each do |doc|
      if is_corrupted?(doc)
        @message_text += "#{doc.document_file_name} is corrupted on this claim and has been deleted\n"
        doc.destroy if is_corrupted?(doc)
      end
    end
  end

  def copy_documents_from_source_claim
    @source_claim.documents.each { |doc| copy_document_to_clone(doc) }
  end

  def copy_document_to_clone(source_document)
    cloned_document = nil
    begin
      cloned_document = create_cloned_document(source_document)
    rescue Errno::ENOENT
      sleep 1
      cloned_document = create_cloned_document(source_document)
    end
    cloned_document.save_and_verify
    source_claim = "#{@source_claim.id} (#{@source_claim.case_number}"
    @message_text += "#{source_document.document_file_name} has been copied from source claim #{source_claim})\n"
  end

  def create_cloned_document(source_document)
    Document.new(
      claim: @cloned_claim,
      document: source_document.document,
      document_content_type: source_document.document_content_type,
      external_user: source_document.external_user
    )
  end

  def is_corrupted?(doc)
    begin
      downloaded_file = Paperclip.io_adapters.for(doc.document).path
    rescue StandardError
      return true
    end
    File.stat(downloaded_file).size.zero?
  end
end
