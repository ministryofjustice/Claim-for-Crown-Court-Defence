# == Schema Information
#
# Table name: defendants
#
#  id                               :integer          not null, primary key
#  first_name                       :string(255)
#  middle_name                      :string(255)
#  last_name                        :string(255)
#  date_of_birth                    :date
#  order_for_judicial_apportionment :boolean
#  claim_id                         :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  uuid                             :uuid
#

class Defendant < ActiveRecord::Base
  belongs_to :claim

  has_many  :representation_orders, dependent: :destroy, inverse_of: :defendant  

  validates :claim,      presence: true
  validates :first_name, presence: true, if: :perform_validation?
  validates :last_name,  presence: true, if: :perform_validation?
  
  validate  :has_at_least_one_representation_order_unless_draft

  validates_with DefendantDateValidator

  validates_associated :representation_orders

  acts_as_gov_uk_date :date_of_birth

  accepts_nested_attributes_for :representation_orders, reject_if: :all_blank,  allow_destroy: true


  def name
      [first_name, middle_name, last_name].join(' ').gsub("  ", " ") # when no middle name is provided, two spaces appear in between fist and last names - gsub resolves this
  end

  def perform_validation?
    claim && claim.perform_validation?
  end

  def representation_order_details
    representation_orders.map(&:detail)
  end

  private

  def has_at_least_one_representation_order_unless_draft
    return if self.claim.nil? || self.claim.draft?
    if self.representation_orders.none?
      errors[:representation_orders] << I18n.t("activerecord.errors.models.defendant.attributes.representation_orders.blank")
    end
  end
end
