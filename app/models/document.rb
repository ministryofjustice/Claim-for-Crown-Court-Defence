class Document < ActiveRecord::Base

  after_save :duplicate_attachment_as_pdf
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

  belongs_to :claim
  belongs_to :document_type

  validates :document_type, presence: true

  def duplicate_attachment_as_pdf
    unless File.extname(document_file_name).downcase == '.pdf' ||
      Libreconv.convert(original_path, "#{target_path}/#{new_filename}")
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

end