class Document < ActiveRecord::Base
  has_attached_file :document


  belongs_to :claim

  #validates :claim, presence: true
  #validates :description, presence: true
  #validates :document, presence: true
end
