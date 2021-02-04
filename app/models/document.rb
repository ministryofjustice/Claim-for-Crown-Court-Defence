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

class Document < ApplicationRecord
  include DocumentAttachment
  include Duplicable

  belongs_to :external_user
  belongs_to :creator, class_name: 'ExternalUser'
  belongs_to :claim, class_name: 'Claim::BaseClaim'

  alias attachment document # to have a consistent interface to both Document and Message
  delegate :provider_id, to: :external_user

  validate :documents_count

  def copy_from(original_doc, verify: false)
    document.attach original_doc.document.blob
    converted_preview_document.attach original_doc.converted_preview_document.blob
    update(verified: original_doc.verified)
  end

  def save_and_verify
    self.verified = true
    save
  end

  # TODO: Remove this method, which exists for backward compatibility with Paperclip
  def document_file_name
    document.filename
  end

  # TODO: Remove this method, which exists for backward compatibility with Paperclip
  def document_file_size
    document.byte_size
  end

  private

  def generate_log_stuff(type, action, message)
    LogStuff.send(type,
                  :paperclip,
                  action: action,
                  document_id: id,
                  claim_id: claim_id,
                  filename: document_file_name, form_id: form_id) { message }
  end

  def documents_count
    return true if form_id.nil?
    count = Document.where(form_id: form_id).count
    max_doc_count = Settings.max_document_upload_count
    return unless count >= max_doc_count
    errors.add(:document, "Total documents exceed maximum of #{max_doc_count}. This document has not been uploaded.")
  end
end
