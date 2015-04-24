class DocumentType < ActiveRecord::Base
  has_many :documents, dependent: :nullify

  validates :description, presence: true, uniqueness: { case_sensitive: false }
end
