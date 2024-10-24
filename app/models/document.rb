class Document < ApplicationRecord
  include Duplicable
  include ActionView::Helpers::NumberHelper

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
              application/rtf
              image/jpeg
              image/png
              image/tiff
              image/bmp
            ]

  alias attachment document # to have a consistent interface to both Document and Message
  delegate :provider_id, to: :external_user

  after_create :convert_document

  before_destroy :purge_attachments

  def copy_from(original)
    document.attach(original.document.blob)
    if original.converted_preview_document.attached?
      converted_preview_document.attach(original.converted_preview_document.blob)
    end
    self.verified = original.verified
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
    # This is to replicate old Paperclip behavour. The controller tests attempted to submit with an empty string instead
    # of a file upload. This should never happen unless the front-end is broken.
    errors.add(:base, e.message)
    self.verified = false
  end

  def document_file_name
    document.filename if document.attached?
  end

  def document_file_size
    document.byte_size if document.attached?
  end

  def document_file_size_in_kb
    number_to_human_size(document.byte_size) if document.attached?
  end

  def document_date_added
    document.created_at.strftime('%m/%d/%y')
  end

  private

  def documents_count
    return true if form_id.nil?
    count = Document.where(form_id:).count
    max_doc_count = Settings.max_document_upload_count
    return unless count >= max_doc_count
    errors.add(:document, "Total documents exceed maximum of #{max_doc_count}. This document has not been uploaded.")
  end

  def convert_document
    ConvertDocumentJob.set(wait: 30.seconds).perform_later(to_param)
  end

  def purge_attachments
    document.purge
    converted_preview_document.purge
  end
end
