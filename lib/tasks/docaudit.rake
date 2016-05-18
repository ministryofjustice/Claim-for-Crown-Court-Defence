desc 'rake task to audit the docs in the system after reports of docs going missing'
task :docaudit => :environment do
  DocAudit.new.run
end


class DocAudit
  def initialize
    @results = []
    @results << %w{ doc_id claim_id path size created_at }
  end

  def run
    docs = Document.all
    docs.each { |doc| audit(doc) }
  end


  private
  def audit(doc)
    line = []
    line << doc.id
    line << doc.claim_id
    line << doc.document.path
    local_file = Paperclip.io_adapters.for(doc.document).path
    line << File.stat(local_file).size
    line << doc.created_at.to_s(:db)
    @results << line
    puts line.join(', ')
    File.unlink(local_file)
  end
end