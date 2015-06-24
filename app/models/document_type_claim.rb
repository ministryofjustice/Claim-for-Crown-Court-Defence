# == Schema Information
#
# Table name: document_type_claims
#
#  id               :integer          not null, primary key
#  claim_id         :integer          not null
#  document_type_id :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#

class DocumentTypeClaim < ActiveRecord::Base

	belongs_to :claim
	belongs_to :document_type

	validates  :claim, :document_type, presence: true

end
