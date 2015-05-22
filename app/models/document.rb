class Document < ActiveRecord::Base

  before_save :duplicate_attachment_as_pdf
  after_save :add_converted_preview_document
  has_attached_file :converted_preview_document
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

  def duplicate_attachment_as_pdf
    unless File.extname(document_file_name).downcase == '.pdf'
      begin
        Libreconv.convert(original_path, "#{target_path}/#{new_filename}") # Libreoffice exe must be in PATH
      rescue IOError => e # raised if Libreoffice exe is not in PATH
        # log the error somehow?
      end
    end
  end

  def add_converted_preview_document
    if self.has_pdf_duplicate?
      self.converted_preview_document = File.open(path_to_pdf_duplicate)
    end
  end

  def original_path
    Paperclip.io_adapters.for(self.document).path
  end

  def target_path
    path = document.path.slice(/(^.*\/)/)
    system 'mkdir', '-p', path
    return path 
  end

  def new_filename
    document_file_name.split('.')[0] + '.pdf'
  end

  def path_to_pdf_duplicate
    Paperclip.io_adapters.for(self.document).path.split('.')[0] + '.pdf'
  end

  def has_pdf_duplicate?
    File.exist?(path_to_pdf_duplicate)
  end

end
