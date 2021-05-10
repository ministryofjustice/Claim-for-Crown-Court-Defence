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

class ExternalUser < ApplicationRecord
  SUPPLIER_NUMBER_REGEX = /\A[0-9A-Z]{5}\z/.freeze

  auto_strip_attributes :supplier_number, squish: true, nullify: true

  ROLES = %w[admin advocate litigator].freeze
  include Roles
  include SoftlyDeletable

  belongs_to :provider

  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  has_many :claims, -> { active }, dependent: :destroy, class_name: 'Claim::BaseClaim'
  has_many :claims_created, -> { active }, dependent: :nullify, class_name: 'Claim::BaseClaim',
                                           foreign_key: 'creator_id', inverse_of: :creator
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

  class EligibleRoles
    attr_reader :provider

    delegate :t, to: 'I18n'

    RoleDescriptor = Struct.new(:id, :label, :hint) do
      def to_s
        id.to_s
      end
    end

    def self.for(provider)
      new(provider).for
    end

    def initialize(provider)
      @provider = provider
    end

    def for
      if provider.agfs? && provider.lgfs?
        [admin, advocate, litigator]
      elsif provider.agfs?
        [admin, advocate]
      elsif provider.lgfs?
        [admin, litigator]
      elsif provider.nil?
        [admin]
      else
        raise "Provider has no valid roles available: #{Provider::ROLES.join(', ')}"
      end
    end

    private

    def descriptors
      {
        admin: RoleDescriptor.new(:admin, t('roles.admin.label'), t('roles.admin.hint')),
        advocate: RoleDescriptor.new(:advocate, t('roles.advocate.label'), t('roles.advocate.hint')),
        litigator: RoleDescriptor.new(:litigator, t('roles.litigator.label'), t('roles.litigator.hint'))
      }
    end

    def admin
      descriptors[:admin]
    end

    def advocate
      descriptors[:advocate]
    end

    def litigator
      descriptors[:litigator]
    end
  end

  def available_roles
    EligibleRoles.for(provider)
  end

  def advocate_claim_types
    [Claim::AdvocateClaim, Claim::AdvocateInterimClaim, Claim::AdvocateSupplementaryClaim, Claim::AdvocateHardshipClaim]
  end

  def litigator_claim_types
    [Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim, Claim::LitigatorHardshipClaim]
  end

  def available_claim_types
    roles.inject([]) do |claim_types, role|
      claim_types | claim_types_for(role)
    end
  end

  def name_and_number
    "#{user.last_name}, #{user.first_name} (#{supplier_number})"
  end

  def before_soft_delete
    user.soft_delete
  end

  def supplier_number
    self[:supplier_number] || provider&.firm_agfs_supplier_number
  end

  def message_claim_path
    'external_users_claim_path'
  end

  private

  def validate_supplier_number?
    provider&.chamber? && advocate?
  end

  # TODO: i believe this is flawed (an admin should delegate available claim types to the provider)
  # e.g. an admin in an agfs provider can only create advocate claims
  def claim_types_for(role)
    {
      'admin' => advocate_claim_types | litigator_claim_types,
      'advocate' => advocate_claim_types,
      'litigator' => litigator_claim_types
    }[role.to_s] || []
  end
end
