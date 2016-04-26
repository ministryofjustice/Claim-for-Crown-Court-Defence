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
  SUPPLIER_NUMBER_REGEX ||= /\A[0-9a-zA-Z]{5}\z/

  auto_strip_attributes :supplier_number, squish: true, nullify: true

  ROLES = %w{ admin advocate litigator }
  include Roles

  belongs_to :provider

  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  has_many :claims, dependent: :destroy, class_name: 'Claim::BaseClaim'
  has_many :claims_created, dependent: :nullify, class_name: 'Claim::BaseClaim', foreign_key: 'creator_id', inverse_of: :creator
  has_many :documents # Do not destroy - ultimately belong to chambers.

  default_scope { includes(:user, :provider) }

  validates :user, presence: true
  validates :provider, presence: true
  validates :supplier_number, presence: true, if: :validate_supplier_number?
  validates :supplier_number, format: { with: SUPPLIER_NUMBER_REGEX, allow_nil: true }, if: :validate_supplier_number?

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

  def litigator_claim_types
    litigator_claim_types = [Claim::LitigatorClaim]
    litigator_claim_types.concat [Claim::InterimClaim] if Settings.allow_lgfs_interim_fees?
    litigator_claim_types.concat [Claim::TransferClaim] if Settings.allow_lgfs_transfer_fees?
    litigator_claim_types
  end

  def available_claim_types
    claim_types = []
    self.roles.each do |role|
      claim_types = [ Claim::AdvocateClaim, *litigator_claim_types ] if role == 'admin'
      claim_types.concat [ Claim::AdvocateClaim ] if role == 'advocate'
      claim_types.concat litigator_claim_types if role == 'litigator'
    end
    claim_types.uniq
  end

  def name_and_number
    "#{self.user.last_name}, #{self.user.first_name}: #{self.supplier_number}"
  end

  private

  def validate_supplier_number?
    self.provider && self.provider.chamber? && self.advocate?
  end
end
