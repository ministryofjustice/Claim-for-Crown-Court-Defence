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

  scope :non_basic, -> { where('abbreviation != ?', 'BASIC').order(:name) }

  def self.basic 
    FeeCategory.where('abbreviation = ?', 'BASIC').first
  end

  def self.misc 
    FeeCategory.where('abbreviation = ?', 'MISC').first
  end


  def self.fixed 
    FeeCategory.where('abbreviation = ?', 'FIXED').first
  end

  def self.non_basic
    FeeCategory.where('abbreviation != ?', 'BASIC')
  end


  def is_basic?
    self.abbreviation == 'BASIC'
  end


end
