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

class RepresentationOrder < ApplicationRecord
  include Duplicable

  auto_strip_attributes :maat_reference, squish: true, nullify: true

  before_save :upcase_maat_ref

  before_validation do
    case_type = defendant&.claim&.case_type
    self.maat_reference = nil if case_type&.requires_maat_reference?.eql?(false)
  end

  default_scope { order(:id) }

  belongs_to :defendant
  validates_with RepresentationOrderValidator

  def claim
    defendant.try(:claim)
  end

  def upcase_maat_ref
    maat_reference.upcase! if maat_reference.present?
  end

  def detail
    "#{representation_order_date.try(:strftime, Settings.date_format)} #{maat_reference}".squish
  end

  def perform_validation?
    claim&.perform_validation?
  end

  def reporders_for_same_defendant
    if defendant.nil?
      []
    else
      defendant.representation_orders
    end
  end

  def first_reporder_for_same_defendant
    reporders_for_same_defendant.first
  end

  def is_first_reporder_for_same_defendant?
    self == first_reporder_for_same_defendant
  end
end
