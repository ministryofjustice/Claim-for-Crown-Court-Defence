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
  belongs_to :expense

  validates :date, presence: true
  validates :fee, presence:  true, if: "expense.nil?"
  validates :expense, presence:  true, if: "fee.nil?"
  validate  :belongs_to_fee_or_expense

  def belongs_to_fee_or_expense
    unless (fee.present? && expense.nil?) || (fee.nil? && expense.present?) || (fee.nil? && expense.nil?)
        errors.add(:fee, 'dates attended cannot also belong to an expense')
        errors.add(:expense, 'dates attended cannot also belong to a fee')
    end
  end

  def to_s
    unless date_to.nil?
      "#{date.strftime(Settings.date_format)} - #{date_to.strftime(Settings.date_format)}"
    else
      "#{date.strftime(Settings.date_format)}"
    end
  end
end
