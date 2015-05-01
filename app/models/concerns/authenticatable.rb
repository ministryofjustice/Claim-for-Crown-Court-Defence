module Authenticatable
  extend ActiveSupport::Concern

  included do
    has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy

    validates :user, presence: true

    accepts_nested_attributes_for :user

    delegate :email, to: :user
  end
end
