# == Schema Information
#
# Table name: schemes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  start_date :date
#  end_date   :date
#

class Scheme < ActiveRecord::Base
  has_many :claims

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :start_date, presence: true, uniqueness: true
  validates :end_date, uniqueness: true, allow_nil: true


  def self.for_date(date)
    Scheme.where('start_date <= :date AND (end_date >= :date OR end_date IS NULL)', date: date).first
  end
end
