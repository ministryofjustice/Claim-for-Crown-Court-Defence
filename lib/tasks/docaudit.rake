desc 'rake task to audit the docs in the system after reports of docs going missing'
task :docaudit => :environment do
  DocAudit.new.run
end


class DocAudit
  def initialize
    @results = []
    @results << %w{ doc_id claim_id case_number defendants path size created_at notes }
  end

  def run
    docs = Document.all
    docs.each { |doc| audit(doc) }
    @results.each do |line|
      puts line.join(',')
    end
  end


  private
  def audit(doc)
    line = []
    line << doc.id
    line << doc.claim_id
    if doc.claim_id
      line << doc.claim.case_number
      line << doc.claim.defendants.map(&:name).join(';')
    end
    line << doc.document.path
    begin
      local_file = Paperclip.io_adapters.for(doc.document).path
      line << File.stat(local_file).size
      line << doc.created_at.to_s(:db)
      File.unlink(local_file)
    rescue => err
      line << nil
      line << nil
      line << "#{err.class} - #{err.message}"
    end
    @results << line
  end
end