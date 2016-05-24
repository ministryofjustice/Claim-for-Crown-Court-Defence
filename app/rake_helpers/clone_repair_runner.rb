require 'csv'
class CloneRepairRunner

  def initialize
    @filename = File.join(Rails.root, 'db', 'data', 'CCCD_MissingDocsRegister.csv')
    @claim_ids = []
  end

  def run
    CSV.foreach(@filename) do |row|
      next if row.first == 'doc_id'
      @claim_ids << row[1].to_i
    end
    @claim_ids.uniq.sort.each do |claim_id|
      ClonedClaimRepairer.new(claim_id).repair!
    end
  end
end