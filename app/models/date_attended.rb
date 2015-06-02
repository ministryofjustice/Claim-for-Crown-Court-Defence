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
end
