class DocumentCleaner
  def clean!
    Document.where(claim_id: nil).find_each(&:destroy)
  end
end
