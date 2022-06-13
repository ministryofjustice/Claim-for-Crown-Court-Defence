# == Schema Information
#
# Table name: dates_attended
#
#  id                 :integer          not null, primary key
#  date               :date
#  created_at         :datetime
#  updated_at         :datetime
#  date_to            :date
#  uuid               :uuid
#  attended_item_id   :integer
#  attended_item_type :string
#

class DateAttended < ApplicationRecord
  include Duplicable

  belongs_to :attended_item, polymorphic: true

  validates_with DateAttendedValidator

  acts_as_gov_uk_date :date_to,
                      validate_if: :perform_validation?,
                      error_clash_behaviour: :override_with_gov_uk_date_field_error

  def claim
    attended_item.try(:claim)
  end

  def perform_validation?
    claim&.perform_validation?
  end

  def earliest_date_before_reporder
    attended_item.try(:claim).earliest_representation_order_date
  end

  def to_s
    return '' if date.nil?
    if date_to.nil?
      date.strftime(Settings.date_format).to_s
    else
      "#{date.strftime(Settings.date_format)} - #{date_to.strftime(Settings.date_format)}"
    end
  end
end
