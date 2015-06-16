class EvidenceListItemClaim < ActiveRecord::Base

	belongs_to :claim
	belongs_to :evidence_list_item

	validates  :claim, :evidence_list_item, presence: true

end