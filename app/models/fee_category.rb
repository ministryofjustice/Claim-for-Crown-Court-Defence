# == Schema Information
#
# Table name: fee_categories
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  abbreviation :string(255)
#

class FeeCategory < ActiveRecord::Base
  has_many :fee_types, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :abbreviation, presence: true, uniqueness: {case_sensitive: false}
end
