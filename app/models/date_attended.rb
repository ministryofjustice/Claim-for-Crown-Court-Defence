# == Schema Information
#
# Table name: dates_attended
#
#  id                 :integer          not null, primary key
#  date               :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  date_to            :datetime
#  uuid               :uuid
#  attended_item_id   :integer
#  attended_item_type :string(255)
#

class DateAttended < ActiveRecord::Base

  belongs_to :attended_item, polymorphic: true

  validates :date, presence: true

  def to_s
    unless date_to.nil?
      "#{date.strftime(Settings.date_format)} - #{date_to.strftime(Settings.date_format)}"
    else
      "#{date.strftime(Settings.date_format)}"
    end
  end

end
