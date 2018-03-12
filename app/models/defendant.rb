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
  has_many :representation_orders, dependent: :destroy, inverse_of: :defendant

  validates_with DefendantValidator
  validates_with DefendantSubModelValidator

  acts_as_gov_uk_date :date_of_birth,
                      validate_if: :validate_date?,
                      error_clash_behaviour: :override_with_gov_uk_date_field_error

  accepts_nested_attributes_for :representation_orders, reject_if: :all_blank, allow_destroy: true

  def name
    [first_name, last_name].join(' ').gsub('  ', ' ')
  end

  def name_and_initial
    first_name && last_name ? "#{first_name.first}. #{last_name}" : ''
  end

  def perform_validation?
    claim&.perform_validation?
  end

  def representation_order_details
    representation_orders.map(&:detail)
  end

  def validate_date?
    perform_validation? && claim&.case_type.present?
  end

  def earliest_representation_order
    return if representation_orders.empty?
    representation_orders.select do |ro|
      ro.representation_order_date.present?
    end.sort_by(&:representation_order_date).first
  end
end
