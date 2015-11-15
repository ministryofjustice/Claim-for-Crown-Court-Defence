class SuperAdmin < ActiveRecord::Base

  # auto_strip_attributes :role, squish: true, nullify: true

  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy

  default_scope { includes(:user) }

  accepts_nested_attributes_for :user

  delegate :email, to: :user
  delegate :first_name, to: :user
  delegate :last_name, to: :user
  delegate :name, to: :user

end