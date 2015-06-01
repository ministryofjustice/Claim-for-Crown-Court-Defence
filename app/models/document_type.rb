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
  has_many :documents, dependent: :nullify

  validates :description, presence: true, uniqueness: { case_sensitive: false }
end
