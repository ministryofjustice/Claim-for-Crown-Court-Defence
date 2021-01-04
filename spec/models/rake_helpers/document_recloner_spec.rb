require 'rails_helper'
require 'fileutils'

describe DocumentRecloner do
  include DatabaseHousekeeping

  before(:all) do
    doc_store = File.join(Rails.root, 'public', 'assets', 'test', 'images')
    FileUtils.rm_r(doc_store) if Dir.exist?(doc_store)
    create :case_worker, :admin
  end

  after(:all) do
    clean_database
  end

  it 'should reclone documents from the source claim' do
    # given a source claim with 4 docs, and a cloned claim with 4 docs, three of which are corrupted
    source_claim = create_source_claim
    cloned_claim = create_cloned_claim(source_claim)
    invalid_doc_ids, valid_doc_ids = analyze_docs(cloned_claim)

    # when I reclone it
    recloner = DocumentRecloner.new(cloned_claim.id)
    recloner.run
    cloned_claim.reload

    # none of the corrupted documents should be attached to the claim
    cloned_docs_ids = cloned_claim.documents.map(&:id)
    invalid_doc_ids.each do |doc_id|
      expect(cloned_docs_ids.include?(doc_id)).to be false
    end

    # the uncorrupted document should be attached to the claim
    valid_doc_ids.each do |doc_id|
      expect(cloned_docs_ids.include?(doc_id)).to be true
    end

    # the total number of documents should be 5
    expect(cloned_claim.documents.size).to eq 5

    # all of the documents should be readable
    cloned_claim.documents.each do |doc|
      expect(file_exists_on_backend?(doc)).to be true
    end

    # a message explaining what has happened should have been attached to the claim
    expect(cloned_claim.messages.last.body).to match(/^SYSTEM NOTICE/)
    expect(cloned_claim.messages.last.body).to match(/repo_order_1.pdf is corrupted on this claim and has been deleted/)
    expect(cloned_claim.messages.last.body).to match(/LAC_1.pdf is corrupted on this claim and has been deleted/)
    expect(cloned_claim.messages.last.body).to match(/hardship.pdf is corrupted on this claim and has been deleted/)
    expect(cloned_claim.messages.last.body).to match(/repo_order_1.pdf has been copied from source claim/)
    expect(cloned_claim.messages.last.body).to match(/LAC_1.pdf has been copied from source claim /)
    expect(cloned_claim.messages.last.body).to match(/hardship.pdf has been copied from source claim/)
  end

  def file_exists_on_backend?(doc)
    local_file = Paperclip.io_adapters.for(doc.document).path
    File.stat(local_file).size > 0
  end

  def create_source_claim
    claim = create :rejected_claim
    %w{hardship indictment LAC_1 repo_order_1}.each { |doc| add_doc(claim, doc) }
    claim.reload
  end

  def create_cloned_claim(source_claim)
    claim = create :claim, external_user: source_claim.external_user
    claim.update(clone_source_id: source_claim.id)
    %w{hardship LAC_1 repo_order_1}.each { |doc| add_corrupted_doc(claim, doc) }
    add_doc(claim, 'indictment')

    claim.reload
  end

  def add_doc(claim, doc_name)
    full_doc_name = File.join(Rails.root, 'spec', 'fixtures', 'files', "#{doc_name}.pdf")
    file = File.open(full_doc_name)
    doc = Document.new(
      claim: claim,
      document: file,
      document_content_type: 'application/pdf',
      external_user: claim.external_user)
    doc.save_and_verify
  end

  def add_corrupted_doc(claim, doc_name)
    full_doc_name = File.join(Rails.root, 'spec', 'fixtures', 'files', "#{doc_name}.pdf")
    file = File.open(full_doc_name)
    doc = Document.new(
      claim: claim,
      document: file,
      document_content_type: 'application/pdf',
      external_user: claim.external_user)
    doc.save_and_verify
    write_empty_document(doc.document.path)
  end

  def write_empty_document(full_path)
    FileUtils.rm full_path
    FileUtils.touch full_path
  end

  def  analyze_docs(claim)
    invalid_doc_ids = []
    valid_doc_ids = []

    claim.documents.each do |doc|
      check_file_has_been_written(doc)
      size = File.stat(doc.document.path).size
      size > 0 ? valid_doc_ids << doc.id : invalid_doc_ids << doc.id
    end
    [invalid_doc_ids, valid_doc_ids]
  end

  def check_file_has_been_written(doc)
    5.times do
      return if File.exist?(doc.document.path)
      sleep 0.5
    end
    raise "Unable to find file #{doc.document.path}"
  end
end
