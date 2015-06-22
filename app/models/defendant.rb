# == Schema Information
#
# Table name: defendants
#
#  id                               :integer          not null, primary key
#  first_name                       :string(255)
#  middle_name                      :string(255)
#  last_name                        :string(255)
#  date_of_birth                    :datetime
#  representation_order_date        :datetime
#  order_for_judicial_apportionment :boolean
#  maat_reference                   :string(255)
#  claim_id                         :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#

class Defendant < ActiveRecord::Base
  belongs_to :claim

  has_many  :representation_orders, dependent: :destroy, inverse_of: :defendant  # This is really a has_one, but needs to be has_many for cocoon

  validates :claim, presence: true
  validates :first_name, presence: true, unless: -> { self.claim.nil? || self.claim.draft? }
  validates :last_name, presence: true, unless: -> { self.claim.nil? || self.claim.draft? }
  validates :date_of_birth, presence: true, unless: -> { self.claim.nil? || self.claim.draft? }
  validates :maat_reference, presence: true, unless: -> { self.claim.nil? || self.claim.draft? }
  validates :maat_reference, uniqueness: { case_sensitive: false, scope: :claim_id }

  validate  :has_at_least_one_representation_order_unless_draft

  before_save { |defendant| defendant.maat_reference = defendant.maat_reference.upcase }

  accepts_nested_attributes_for :representation_orders, reject_if: :all_blank,  allow_destroy: true

  after_initialize :build_representation_order

  def build_representation_order
    if new_record?
      representation_orders.build
    end
  end


  def name
    [first_name, last_name].join(' ')
  end

  private

  def has_at_least_one_representation_order_unless_draft
    return if self.claim.nil? || self.claim.draft?
    if self.representation_orders.none?
      errors[:representation_orders] << "There must be at least one representation order per defendant"
    end
  end
end
