# == Schema Information
#
# Table name: providers
#
#  id              :integer          not null, primary key
#  name            :string
#  supplier_number :string
#  provider_type   :string
#  vat_registered  :boolean
#  uuid            :uuid
#  api_key         :uuid
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  roles           :string
#

class Provider < ActiveRecord::Base
  auto_strip_attributes :name, :supplier_number, squish: true, nullify: true

  PROVIDER_TYPES = %w( chamber firm )

  ROLES = %w( agfs lgfs )
  include Roles

  PROVIDER_TYPES.each do |type|
    define_method "#{type}?" do
      provider_type == type
    end

    scope type.pluralize.to_sym, -> { where(provider_type: type) }
  end

  has_many :external_users, dependent: :destroy do
    def ordered_by_last_name
      self.sort { |a, b| a.user.sortable_name <=> b.user.sortable_name }
    end
  end

  has_many :claims, through: :external_users

  before_validation :set_api_key

  validates :provider_type, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :supplier_number, presence: true, uniqueness: { case_sensitive: false }, if: :firm?
  validates :api_key, presence: true

  # Allows calling of provider.admins or provider.advocates
  ExternalUser::ROLES.each do |role|
    delegate role.pluralize.to_sym, to: :external_users
  end

  def regenerate_api_key!
    update_column(:api_key, SecureRandom.uuid)
  end

  private

  def set_api_key
    self.api_key ||= SecureRandom.uuid
  end
end
