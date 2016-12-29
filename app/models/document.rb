# == Schema Information
#
# Table name: documents
#
#  id                                      :integer          not null, primary key
#  claim_id                                :integer
#  created_at                              :datetime
#  updated_at                              :datetime
#  document_file_name                      :string
#  document_content_type                   :string
#  document_file_size                      :integer
#  document_updated_at                     :datetime
#  external_user_id                        :integer
#  converted_preview_document_file_name    :string
#  converted_preview_document_content_type :string
#  converted_preview_document_file_size    :integer
#  converted_preview_document_updated_at   :datetime
#  uuid                                    :uuid
#  form_id                                 :string
#  creator_id                              :integer
#  verified_file_size                      :integer
#  file_path                               :string
#  verified                                :boolean          default(FALSE)
#

class Document < ActiveRecord::Base
  include DocumentAttachment
  include Duplicable

  belongs_to :external_user
  belongs_to :creator, foreign_key: 'creator_id', class_name: 'ExternalUser'
  belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id

  validates_attachment :document,
    presence: { message: 'Document must have an attachment' },
    size: { in: 0.megabytes..20.megabytes },
    content_type: {
      content_type: ['application/pdf',
                     'application/msword',
                     'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                     'application/vnd.oasis.opendocument.text',
                     'text/rtf',
                     'application/rtf',
                     'image/jpeg',
                     'image/png',
                     'image/tiff',
                     'image/bmp',
                     'image/x-bitmap'
                     ]}

  alias attachment document # to have a consistent interface to both Document and Message
  delegate :provider_id, to: :external_user

  before_save :generate_pdf_tmpfile
  before_save :add_converted_preview_document

  validate :documents_count

  def copy_from(original_doc, verify: false)
    self.document = original_doc.document
    verify ? save_and_verify : save
  end

  def save_and_verify
    result = save
    if result
      result = verify_and_log
    else
      transform_cryptic_paperclip_error
      log_save_error
    end
    result
  end

  def verify_and_log
    LogStuff.info(:paperclip, action: 'save', document_id: self.id, claim_id: self.claim_id, filename: self.document_file_name, form_id: self.form_id) { 'Document saved' }
    if verify_file_exists
      LogStuff.info(:paperclip, action: 'verify', document_id: self.id, claim_id: self.claim_id, filename: self.document_file_name, form_id: self.form_id) { 'Document verified' }
      result = true
    else
      LogStuff.error(:paperclip, action: 'verify_fail', document_id: self.id, claim_id: self.claim_id, filename: self.document_file_name, form_id: self.form_id) { 'Unable to verify document' }
      self.errors[:document] << "Unable to save the file - please retry" if self.verified_file_size == 0
      result = false
    end
    result
  end

  def log_save_error
    LogStuff.error(:paperclip, action: 'save_fail', document_id: self.id, claim_id: self.claim_id, filename: self.document_file_name, form_id: self.form_id) { 'Unable to save document' }
  end

  private

  def verify_file_exists
    begin
      reloaded_file = reload_saved_file
      self.verified_file_size = File.stat(reloaded_file).size
      self.file_path = self.document.path
      self.verified = self.verified_file_size > 0
      self.save!
    rescue => err
      puts err.class
      self.errors[:document] << err.message
      self.verified = false
    end
    self.verified
  end

  def reload_saved_file
    Paperclip.io_adapters.for(self.document).path
  end


  def documents_count
    return true if self.form_id.nil?
    count = Document.where(form_id: self.form_id).count
    if count >= Settings.max_document_upload_count
      errors.add(:document, "Total documents exceed maximum of #{Settings.max_document_upload_count}. This document has not been uploaded.")
    end
  end

  def transform_cryptic_paperclip_error
    if self.errors[:document].include?('has contents that are not what they are reported to be')
      self.errors[:document].delete('has contents that are not what they are reported to be')
      self.errors[:document] << 'The contents of the file do not match the file extension'
    end
  end
end
