class DocumentCleaner
  def clean!
    Document.where(claim_id: nil).each(&:destroy)
  end
end
