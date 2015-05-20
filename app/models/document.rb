class Document < ActiveRecord::Base

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

  validates :document_type, presence: true
end
