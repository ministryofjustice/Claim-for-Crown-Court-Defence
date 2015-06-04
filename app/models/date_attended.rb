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
  belongs_to :fee

  validates :date, presence: true

  def to_s
    unless date_to.nil?
      "#{date.strftime('%d/%m/%y')} - #{date_to.strftime('%d/%m/%y')}"
    else
      "#{date.strftime('%d/%m/%y')}"
    end
  end
end
