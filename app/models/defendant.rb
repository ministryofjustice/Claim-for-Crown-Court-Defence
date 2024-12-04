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

class Defendant < ApplicationRecord
  include Duplicable
  auto_strip_attributes :first_name, :last_name, squish: true, nullify: true

  belongs_to :claim, class_name: 'Claim::BaseClaim'
  has_many :representation_orders, dependent: :destroy, inverse_of: :defendant

  validates_with DefendantValidator
  validates_with DefendantSubModelValidator

  accepts_nested_attributes_for :representation_orders, reject_if: :all_blank, allow_destroy: true

  # Do we still need this name method now we are using first name
  # and last name on the summary page instead?
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
    end.min_by(&:representation_order_date)
  end
end
