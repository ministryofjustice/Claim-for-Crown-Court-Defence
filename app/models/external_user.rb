# == Schema Information
#
# Table name: external_users
#
#  id              :integer          not null, primary key
#  roles           :string
#  provider_id     :integer
#  created_at      :datetime
#  updated_at      :datetime
#  supplier_number :string
#  uuid            :uuid
#

class ExternalUser < ActiveRecord::Base
  auto_strip_attributes :supplier_number, squish: true, nullify: true

  ROLES = %w{ admin advocate }
  include UserRoles

  belongs_to :provider

  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  has_many :claims,  -> { includes :fee_types }, dependent: :destroy
  has_many :claims_created, dependent: :nullify, class_name: 'Claim', foreign_key: 'creator_id', inverse_of: :creator
  has_many :documents # Do not destroy - ultimately belong to chambers.

  default_scope { includes(:user, :provider) }

  validates :user, presence: true
  validates :provider, presence: true
  validates :supplier_number, presence: true, if: :validate_supplier_number?
  validates :supplier_number, format: { with: /\A[a-zA-Z0-9]{5}\z/, allow_nil: true }, if: :validate_supplier_number?

  accepts_nested_attributes_for :user

  delegate :email, to: :user
  delegate :first_name, to: :user
  delegate :last_name, to: :user
  delegate :name, to: :user

  def supplier_number
    if provider && provider.firm?
      provider.supplier_number
    else
      read_attribute(:supplier_number)
    end
  end

  def vat_registered?
    if provider && provider.firm?
      provider.vat_registered?
    else
      vat_registered
    end
  end

  def name_and_number
    "#{self.user.last_name}, #{self.user.first_name}: #{self.supplier_number}"
  end

  private

  def validate_supplier_number?
    self.provider && self.provider.chamber? && self.advocate?
  end
end
