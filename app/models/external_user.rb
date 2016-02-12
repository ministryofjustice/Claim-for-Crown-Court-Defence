# == Schema Information
#
# Table name: external_users
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  supplier_number :string
#  uuid            :uuid
#  vat_registered  :boolean          default(TRUE)
#  provider_id     :integer
#  roles           :string
#

class ExternalUser < ActiveRecord::Base
  auto_strip_attributes :supplier_number, squish: true, nullify: true

  ROLES = %w{ admin advocate litigator }
  include Roles

  belongs_to :provider

  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  has_many :claims,  -> { includes :fee_types }, dependent: :destroy, class_name: 'Claim::BaseClaim'
  has_many :claims_created, dependent: :nullify, class_name: 'Claim::BaseClaim', foreign_key: 'creator_id', inverse_of: :creator
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

  Provider::ROLES.each do |role|
    delegate "#{role}?".to_sym, to: :provider
  end

  def available_roles
    return %w( admin ) if provider.nil?

    if provider.agfs? && provider.lgfs?
      %w( admin advocate litigator )
    elsif provider.agfs?
      %w( admin advocate )
    elsif provider.lgfs?
      %w( admin litigator )
    else
      raise "Provider has no valid roles available: #{Provider::ROLES.join(', ')}"
    end
  end

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
