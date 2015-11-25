class Provider < ActiveRecord::Base
  auto_strip_attributes :name, :supplier_number, squish: true, nullify: true

  PROVIDER_TYPES = %w( chamber firm )

  PROVIDER_TYPES.each do |type|
    define_method "#{type}?" do
      provider_type == type
    end

    scope type.pluralize.to_sym, -> { where(provider_type: type) }
  end

  before_validation :set_api_key

  validates :provider_type, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :supplier_number, presence: true, uniqueness: { case_sensitive: false }, if: :firm?
  validates :api_key, presence: true

  def regenerate_api_key!
    update_column(:api_key, SecureRandom.uuid)
  end

  private

  def set_api_key
    self.api_key ||= SecureRandom.uuid
  end
end
