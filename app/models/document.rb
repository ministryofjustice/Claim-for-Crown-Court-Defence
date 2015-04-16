class Document < ActiveRecord::Base
  has_attached_file :document,
    storage: :s3,
    s3_credentials: 'config/aws.yml'

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

    validates :claim, presence: true
    validates :description, presence: true
end
