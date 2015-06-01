# == Schema Information
#
# Table name: chambers
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  account_number :string(255)
#  vat_registered :boolean
#  created_at     :datetime
#  updated_at     :datetime
#

class Chamber < ActiveRecord::Base
  has_many :advocates
  has_many :claims, through: :advocates

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :account_number, presence: true, uniqueness: { case_sensitive: false }
end
