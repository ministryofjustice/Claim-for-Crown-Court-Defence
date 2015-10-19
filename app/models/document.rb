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
#  advocate_id                             :integer
#  converted_preview_document_file_name    :string
#  converted_preview_document_content_type :string
#  converted_preview_document_file_size    :integer
#  converted_preview_document_updated_at   :datetime
#  uuid                                    :uuid
#  form_id                                 :string
#  creator_id                              :integer
#

class Document < ActiveRecord::Base
  include DocumentAttachment

  belongs_to :advocate
  belongs_to :claim

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

  delegate   :chamber_id, to: :advocate

  before_save :generate_pdf_tmpfile
  before_save :add_converted_preview_document

  validate :documents_count

  private

  def documents_count
    return true if self.form_id.nil?

    count = Document.where(form_id: self.form_id).count

    if count >= Settings.max_document_upload_count
      errors.add(:document, "Total documents exceed maximum of #{Settings.max_document_upload_count}. This document has not been uploaded.")
    end
  end

  def documents_upload_size
    total_upload_size = Document.where(form_id: self.form_id).map { |d| d.document_file_size }.sum
    total_upload_size_in_mb = total_upload_size.to_f / (1000*1000)

    if total_upload_size_in_mb > Settings.max_document_upload_size_mb
      errors.add(:document, "Total documents exceeded maximum upload size of #{total_upload_size_in_mb}MB. This document has not been uploaded.")
    end
  end
end
