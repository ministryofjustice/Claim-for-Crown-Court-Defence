class DocumentCleaner
  def clean!
    Document.where(claim_id: nil).each { |d| d.destroy }
  end
end
