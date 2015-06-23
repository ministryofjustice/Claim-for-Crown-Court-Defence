# == Schema Information
#
# Table name: representation_orders
#
#  id                                      :integer          not null, primary key
#  defendant_id                            :integer
#  document_file_name                      :string(255)
#  document_content_type                   :string(255)
#  document_file_size                      :integer
#  document_updated_at                     :datetime
#  converted_preview_document_file_name    :string(255)
#  converted_preview_document_content_type :string(255)
#  converted_preview_document_file_size    :integer
#  converted_preview_document_updated_at   :datetime
#  created_at                              :datetime
#  updated_at                              :datetime
#

class RepresentationOrder < ActiveRecord::Base
  include DocumentAttachment

  belongs_to :defendant

  validates_attachment :document,
    presence: true,
    unless: -> { self.defendant.nil? || self.defendant.claim.nil? || self.defendant.claim.draft? },
    content_type: {
      content_type: ['application/pdf',
                     'application/msword',
                     'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                     'application/vnd.oasis.opendocument.text',
                     'text/rtf',
                     'application/rtf',
                     'image/png']}

  before_save :generate_pdf_tmpfile, unless: -> { self.defendant.nil? || self.defendant.claim.draft? }
  before_save :add_converted_preview_document, unless: -> { self.defendant.nil? || self.defendant.claim.draft? }

  def blank?
    self.document_file_name.blank?
  end

  def present?
    !self.blank?
  end
end
