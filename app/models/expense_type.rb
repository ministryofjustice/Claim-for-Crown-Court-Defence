# == Schema Information
#
# Table name: expense_types
#
#  id         :integer          not null, primary key
#  name       :string
#  roles      :string
#  created_at :datetime
#  updated_at :datetime
#

class ExpenseType < ActiveRecord::Base
  ROLES = %w( agfs lgfs )
  include Roles

  auto_strip_attributes :name, squish: true, nullify: true

  has_many :expenses, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
