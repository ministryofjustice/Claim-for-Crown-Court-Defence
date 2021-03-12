# frozen_string_literal: true

class Cookies
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :analytics

  def self.analytics_state
    %w[true
       false].freeze
  end

  validates :analytics, presence: true
  validates :analytics, inclusion: { in: analytics_state }
end
