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

  has_one_attached :converted_preview_document
  has_one_attached :document

  validate :documents_count
  validates :converted_preview_document, content_type: 'application/pdf'
  validates :document,
            presence: true,
            size: { less_than: 20.megabytes },
            content_type: %w[
              application/pdf
              application/msword
              application/vnd.openxmlformats-officedocument.wordprocessingml.document
              application/vnd.oasis.opendocument.text
              text/rtf
              application/rtf
              image/jpeg
              image/png
              image/tiff
              image/bmp
              image/x-bitmap
            ]

  alias attachment document # to have a consistent interface to both Document and Message
  delegate :provider_id, to: :external_user

  before_save :create_preview_document
  before_save :populate_paperclip_for_document
  before_save :populate_paperclip_for_converted_preview_document

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
  rescue ActiveSupport::MessageVerifier::InvalidSignature => e
    # This is to replecate old Paperclip behavour. The controller tests attempted to submit with an empty string instead
    # of a file upload. This should never happen unless the front-end is broken.
    errors.add(:base, e.message)
    self.verified = false
  end

  private

  def documents_count
    return true if form_id.nil?
    count = Document.where(form_id: form_id).count
    max_doc_count = Settings.max_document_upload_count
    return unless count >= max_doc_count
    errors.add(:document, "Total documents exceed maximum of #{max_doc_count}. This document has not been uploaded.")
  end

  def create_preview_document
    convert_document from: document, to: converted_preview_document
  end

  def populate_paperclip_for_document
    self.document_file_name = document.filename
    self.document_file_size = document.byte_size
    self.document_content_type = document.content_type
    self.document_updated_at = Time.zone.now
    self.as_document_checksum = document.checksum
  end

  # High ABC Size due to setting Paperclip fields for possible revert.
  # This 'rubocop:disable' can be removed when the Paperclip fields are removed.
  # rubocop:disable Metrics/AbcSize
  def populate_paperclip_for_converted_preview_document
    return unless converted_preview_document.attached?

    self.converted_preview_document_file_name = converted_preview_document.filename
    self.converted_preview_document_file_size = converted_preview_document.byte_size
    self.converted_preview_document_content_type = converted_preview_document.content_type
    self.converted_preview_document_updated_at = Time.zone.now
    self.as_converted_preview_document_checksum = converted_preview_document.checksum
  end
  # rubocop:enable Metrics/AbcSize
end
