# == Schema Information
#
# Table name: dates_attended
#
#  id         :integer          not null, primary key
#  date       :datetime
#  fee_id     :integer
#  created_at :datetime
#  updated_at :datetime
#  date_to    :datetime
#

class DateAttended < ActiveRecord::Base

  belongs_to :attended_item, polymorphic: true

  validates :date, presence: true
  validates :attended_item, presence: true

  def to_s
    unless date_to.nil?
      "#{date.strftime(Settings.date_format)} - #{date_to.strftime(Settings.date_format)}"
    else
      "#{date.strftime(Settings.date_format)}"
    end
  end
end
