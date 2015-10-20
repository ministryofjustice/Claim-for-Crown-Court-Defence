# == Schema Information
#
# Table name: chambers
#
#  id              :integer          not null, primary key
#  name            :string
#  supplier_number :string
#  vat_registered  :boolean
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :uuid
#  api_key         :uuid
#

class Chamber < ActiveRecord::Base
  auto_strip_attributes :name, :supplier_number, squish: true, nullify: true

  has_many :advocates do
    def ordered_by_last_name
      self.sort { |a, b| a.user.sortable_name <=> b.user.sortable_name }
    end
  end

  has_many :claims, through: :advocates

  before_validation :set_api_key

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :supplier_number, presence: true, uniqueness: { case_sensitive: false }
  validates :api_key, presence: true

private

  def set_api_key
    self.api_key ||= SecureRandom.uuid
  end

end
