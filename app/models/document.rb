class Document < ActiveRecord::Base

  attr_accessor :pdf_tmpfile

  before_save :generate_pdf_tmpfile
  before_save :add_converted_preview_document
  
  has_attached_file :converted_preview_document,
    { s3_headers: {
      'x-amz-meta-Cache-Control' => 'no-cache',
      'Expires' => 3.months.from_now.httpdate
    },
    s3_permissions: :private,
    s3_region: 'eu-west-1'}.merge(PAPERCLIP_STORAGE_OPTIONS)

  has_attached_file :document,
    { s3_headers: {
      'x-amz-meta-Cache-Control' => 'no-cache',
      'Expires' => 3.months.from_now.httpdate
    },
    s3_permissions: :private,
    s3_region: 'eu-west-1'}.merge(PAPERCLIP_STORAGE_OPTIONS)


  validates_attachment :document,
    presence: true,
    content_type: {
      content_type: ['application/pdf',
                     'application/msword',
                     'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                     'application/vnd.oasis.opendocument.text',
                     'text/rtf',
                     'application/rtf',
                     'image/png']}

  belongs_to :advocate
  belongs_to :claim
  belongs_to :document_type
  delegate   :chamber_id, to: :advocate

  validates_attachment_content_type :converted_preview_document, content_type: 'application/pdf'
  validates :document_type, presence: true

  def generate_pdf_tmpfile
    if File.extname(document_file_name).downcase == '.pdf'
      self.pdf_tmpfile = document # if original document is PDF, make tmpfile from original doc
    else
      convert_and_assign_document     
    end
  end

  def convert_and_assign_document # Libreconvert performs both action sin one call
    begin
      self.pdf_tmpfile = File.new("#{Dir.mktmpdir}/#{self.document_file_name}.pdf", 'wb+')
      Libreconv.convert(Paperclip.io_adapters.for(self.document).path, self.pdf_tmpfile) # Libreoffice exe must be in PATH
    rescue IOError => e # raised if Libreoffice exe is not in PATH
    end
  end

  def add_converted_preview_document
    self.converted_preview_document = self.pdf_tmpfile
  end
end
