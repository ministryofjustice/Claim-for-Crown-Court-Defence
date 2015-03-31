class Document < ActiveRecord::Base
  mount_uploader :document, DocumentUploader

  belongs_to :claim

  validates :claim, presence: true
  validates :description, presence: true
  validates :document, presence: true
end
