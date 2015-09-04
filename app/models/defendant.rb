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

  has_many  :representation_orders, dependent: :destroy, inverse_of: :defendant  # This is really a has_one, but needs to be has_many for cocoon

  validates :claim, presence: true
  validates :first_name, presence: true   , unless: :do_not_validate?
  validates :last_name, presence: true    , unless: :do_not_validate?
  validates :date_of_birth, presence: true, unless: :do_not_validate?
  validate  :has_at_least_one_representation_order_unless_draft

  acts_as_gov_uk_date :date_of_birth

  accepts_nested_attributes_for :representation_orders, reject_if: :all_blank,  allow_destroy: true

  def name
      [first_name, middle_name, last_name].join(' ').gsub("  ", " ") # when no middle name is provided, two spaces appear in between fist and last names - gsub resolves this
  end

  def representation_order_details
    representation_orders.map(&:detail)
  end

  private

  def do_not_validate?
    claim.nil? || belongs_to_draft_claim_from_web?
  end

  def belongs_to_draft_claim_from_web?
    claim.state == 'draft' && claim.source == 'web' # validations do apply to drafts from api
  end

  def has_at_least_one_representation_order_unless_draft
    return if self.claim.nil? || self.claim.draft?
    if self.representation_orders.none?
      errors[:representation_orders] << I18n.t("activerecord.errors.models.defendant.attributes.representation_orders.blank")
    end
  end
end
