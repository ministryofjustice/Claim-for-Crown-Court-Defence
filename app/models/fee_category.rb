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

  # NOTE: there is only one category of each type so SCOPES (that always return a relation)
  #       are less useful here.
  def self.basic
    FeeCategory.find_by(abbreviation: 'BASIC')
  end

  def self.misc
    FeeCategory.find_by(abbreviation: 'MISC')
  end

  def self.fixed
    FeeCategory.find_by(abbreviation: 'FIXED')
  end

  def is_basic?
    self.abbreviation == 'BASIC'
  end

  def is_misc?
    self.abbreviation == 'MISC'
  end

  def is_fixed?
    self.abbreviation == 'FIXED'
  end

end
