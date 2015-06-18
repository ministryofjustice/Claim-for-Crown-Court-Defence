# == Schema Information
#
# Table name: document_types
#
#  id          :integer          not null, primary key
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class DocumentType < ActiveRecord::Base

  has_many :document_type_claims, dependent: :nullify
  has_many :claims, through: :document_type_claims

  validates :description, presence: true, uniqueness: { case_sensitive: false }

end
