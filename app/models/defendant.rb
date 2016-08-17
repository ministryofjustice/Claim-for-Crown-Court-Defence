# == Schema Information
#
# Table name: defendants
#
#  id                               :integer          not null, primary key
#  first_name                       :string
#  last_name                        :string
#  date_of_birth                    :date
#  order_for_judicial_apportionment :boolean
#  claim_id                         :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  uuid                             :uuid
#

class Defendant < ActiveRecord::Base
  include Duplicable
  auto_strip_attributes :first_name, :last_name, squish: true, nullify: true

  belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id
  has_many    :representation_orders, dependent: :destroy, inverse_of: :defendant

  validates_with DefendantValidator
  validates_with DefendantSubModelValidator

  acts_as_gov_uk_date :date_of_birth, validate_if: :validate_date?

  accepts_nested_attributes_for :representation_orders, reject_if: :all_blank, allow_destroy: true

  def name
      [first_name, last_name].join(' ').gsub("  ", " ")
  end

  def perform_validation?
    claim && claim.perform_validation?
  end

  def representation_order_details
    representation_orders.map(&:detail)
  end

  def validate_date?
    self.perform_validation? && case_type_requires_date?
  end

  def case_type_requires_date?
    claim&.case_type&.requires_defendant_dob?
  end

end

