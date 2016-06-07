# == Schema Information
#
# Table name: representation_orders
#
#  id                        :integer          not null, primary key
#  defendant_id              :integer
#  created_at                :datetime
#  updated_at                :datetime
#  maat_reference            :string
#  representation_order_date :date
#  uuid                      :uuid
#

class RepresentationOrder < ActiveRecord::Base
  include Duplicable

  auto_strip_attributes :maat_reference, squish: true, nullify: true

  before_save :upcase_maat_ref

  before_validation do
    case_type = defendant.claim.case_type rescue nil
    if case_type && !case_type.requires_maat_reference?
      self.maat_reference = nil
    end
  end

  acts_as_gov_uk_date :representation_order_date, validate_if: :perform_validation?

  default_scope { order('id ASC') }

  belongs_to :defendant
  validates_with RepresentationOrderValidator

  def claim
    self.defendant.try(:claim)
  end

  def upcase_maat_ref
    self.maat_reference.upcase! unless self.maat_reference.blank?
  end

  def detail
    "#{self.representation_order_date.try(:strftime, Settings.date_format)} #{self.maat_reference}".squish
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
