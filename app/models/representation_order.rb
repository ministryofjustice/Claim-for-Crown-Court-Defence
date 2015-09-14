# == Schema Information
#
# Table name: representation_orders
#
#  id                        :integer          not null, primary key
#  defendant_id              :integer
#  created_at                :datetime
#  updated_at                :datetime
#  granting_body             :string(255)
#  maat_reference            :string(255)
#  representation_order_date :date
#  uuid                      :uuid
#

class RepresentationOrder < ActiveRecord::Base

  before_save :upcase_maat_ref

  validates   :granting_body, presence: {message: 'Select the granting body'}, if: :perform_validation?
  validates   :granting_body, inclusion: { in: Settings.court_types, allow_nil: true, message: "Invalid granting body" }
  validates   :maat_reference, presence: true, if: :perform_validation?
  validates   :maat_reference, uniqueness: { case_sensitive: false, message: 'MAAT reference must be unique' }

  validates_with RepresentationOrderDateValidator

  acts_as_gov_uk_date :representation_order_date

  default_scope { order('id ASC') }

  belongs_to :defendant

  def claim
    self.defendant.try(:claim)
  end

  def upcase_maat_ref
    self.maat_reference.upcase! unless self.maat_reference.blank?
  end

  def detail
    "#{self.granting_body} #{self.representation_order_date.strftime(Settings.date_format)} #{self.maat_reference}"
  end

  def perform_validation?
    claim.try(:perform_validation?)
  end

  def reporders_for_same_defendant
    if self.defendant.nil?
      []
    else
      self.defendant.representation_orders
    end
  end

  def first_reporder_for_same_defendant
    reporders_for_same_defendant.first
  end

  def is_first_reporder_for_same_defendant?
    self == first_reporder_for_same_defendant
  end
  
end
