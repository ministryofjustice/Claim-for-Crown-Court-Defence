class DocumentTypeClaim < ActiveRecord::Base

	belongs_to :claim
	belongs_to :document_type

	validates  :claim, :document_type, presence: true

end