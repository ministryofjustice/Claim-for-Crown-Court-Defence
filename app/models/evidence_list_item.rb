class EvidenceListItem < ActiveRecord::Base

	has_many :evidence_list_item_claims, dependent: :destroy
	has_many :claims, through: :evidence_list_item_claims

	validates :description, presence: true, uniqueness: { case_sensitive: false }
	validates :item_order, presence: true, uniqueness: { case_sensitive: false }

end