class Document < ActiveRecord::Base
  has_attached_file :document,
    storage: :s3,
    s3_credentials: 'config/aws.yml',
    s3_headers: {
      'x-amz-meta-Cache-Control' => 'no-cache',
      'Expires' => 3.months.from_now.httpdate
    },
    # s3_host_name: "moj-cbo-documents-#{Rails.env.to_s}.s3.amazonaws.com",
    s3_permissions: :private,
    s3_region: 'eu-west-1',
    path: "documents/:id_partition/:filename"

  validates_attachment :document,
    presence: true,
    content_type: {
      content_type: ['application/pdf',
                     'application/msword',
                     'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                     'application/vnd.oasis.opendocument.text',
                     'text/rtf',
                     'application/rtf']}

    belongs_to :claim

    #validates :claim, presence: true
    #validates :description, presence: true
end
