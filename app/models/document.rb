# == Schema Information
#
# Table name: documents
#
#  id                                      :integer          not null, primary key
#  claim_id                                :integer
#  created_at                              :datetime
#  updated_at                              :datetime
#  document_file_name                      :string(255)
#  document_content_type                   :string(255)
#  document_file_size                      :integer
#  document_updated_at                     :datetime
#  advocate_id                             :integer
#  converted_preview_document_file_name    :string(255)
#  converted_preview_document_content_type :string(255)
#  converted_preview_document_file_size    :integer
#  converted_preview_document_updated_at   :datetime
#  uuid                                    :uuid
#

class Document < ActiveRecord::Base
  include DocumentAttachment

  belongs_to :advocate
  belongs_to :claim

  validates_attachment :document,
    presence: {message: 'Document must have an attachment'},
    content_type: {
      content_type: ['application/pdf',
                     'application/msword',
                     'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                     'application/vnd.oasis.opendocument.text',
                     'text/rtf',
                     'application/rtf',
                     'image/png']}

  delegate   :chamber_id, to: :advocate

  before_save :generate_pdf_tmpfile
  before_save :add_converted_preview_document
end
