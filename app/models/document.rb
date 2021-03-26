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

  def copy_from(other)
    document.attach(other.document.blob)
    converted_preview_document.attach(other.converted_preview_document.blob)
    self.verified = other.verified
  end

  def save_and_verify
    # For backward compatiblity
    # Previously there was a step that marked documents as 'verified' and only these documents are visible to the user.
    # Therefore this flag needs to be set or the documents will not appear. The scope in BaseClaim in the
    # `has_many :documents` clause cannot be remove or documents that were previously marked as unverified would begin
    # to appear. Over time, however, the number of these documents will be reduced and so this field can be removed.
    self.verified = true
    save
  end

  private

  def documents_count
    return true if form_id.nil?
    count = Document.where(form_id: form_id).count
    max_doc_count = Settings.max_document_upload_count
    return unless count >= max_doc_count
    errors.add(:document, "Total documents exceed maximum of #{max_doc_count}. This document has not been uploaded.")
  end
end
