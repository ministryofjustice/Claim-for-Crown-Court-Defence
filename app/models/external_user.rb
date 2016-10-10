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
#  deleted_at      :datetime
#

class ExternalUser < ActiveRecord::Base
  SUPPLIER_NUMBER_REGEX ||= /\A[0-9A-Z]{5}\z/

  auto_strip_attributes :supplier_number, squish: true, nullify: true

  ROLES = %w{ admin advocate litigator }
  include Roles
  include SoftlyDeletable

  belongs_to :provider

  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  has_many :claims, -> { active }, dependent: :destroy, class_name: 'Claim::BaseClaim'
  has_many :claims_created, -> { active }, dependent: :nullify, class_name: 'Claim::BaseClaim', foreign_key: 'creator_id', inverse_of: :creator
  has_many :documents # Do not destroy - ultimately belong to chambers.

  default_scope { includes(:user, :provider) }

  before_validation { supplier_number.upcase! unless supplier_number.blank? }

  validates :user, presence: true
  validates :provider, presence: true
  validates :supplier_number, presence: true, if: :validate_supplier_number?
  validates :supplier_number, format: { with: SUPPLIER_NUMBER_REGEX, allow_nil: true }, if: :validate_supplier_number?

  accepts_nested_attributes_for :user

  delegate :email, to: :user
  delegate :first_name, to: :user
  delegate :last_name, to: :user
  delegate :name, to: :user
  delegate :sortable_name, to: :user
  delegate :email_with_name, to: :user
  delegate :save_settings!, to: :user
  delegate :settings, to: :user
  delegate :email_notification_of_message, to: :user
  delegate :send_email_notification_of_message?, to: :user
  delegate :email_notification_of_message=, to: :user

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
    [Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim]
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

  def before_soft_delete
    self.user.soft_delete
  end


  private

  def validate_supplier_number?
    self.provider && self.provider.chamber? && self.advocate?
  end
end
