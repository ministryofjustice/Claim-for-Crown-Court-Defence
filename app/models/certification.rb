# == Schema Information
#
# Table name: certifications
#
#  id                               :integer          not null, primary key
#  claim_id                         :integer
#  main_hearing                     :boolean
#  notified_court                   :boolean
#  attended_pcmh                    :boolean
#  attended_first_hearing           :boolean
#  previous_advocate_notified_court :boolean
#  fixed_fee_case                   :boolean
#  certified_by                     :string
#  certification_date               :date
#  created_at                       :datetime
#  updated_at                       :datetime
#

class Certification < ActiveRecord::Base
  auto_strip_attributes :certified_by, squish: true, nullify: true

  belongs_to :claim

  validate :one_and_only_one_checkbox_checked
  validate :certification_date_valid
  validate :certified_by_valid

  acts_as_gov_uk_date :certification_date

  private

  def one_and_only_one_checkbox_checked
    num_checked_boxes = [
      self.main_hearing,
      self.notified_court,
      self.attended_pcmh,
      self.attended_first_hearing,
      self.previous_advocate_notified_court,
      self.fixed_fee_case
    ].count(true)
    unless num_checked_boxes == 1
      errors[:base] << "You must check one and only one checkbox on this form"
    end
  end

  def certification_date_valid
    errors[:base] << 'Certification date cannot be blank' if certification_date.blank?
  end

  def certified_by_valid
    errors[:base] << 'Certified by cannot be blank' if certified_by.blank?
  end

end
