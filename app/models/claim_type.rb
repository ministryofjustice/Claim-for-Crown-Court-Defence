# frozen_string_literal: true

class ClaimType
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :id, :string

  def self.valid_ids
    %w[agfs
       agfs_interim
       agfs_supplementary
       agfs_hardship
       lgfs_final
       lgfs_interim
       lgfs_transfer
       lgfs_hardship].freeze
  end

  # TODO move messages to implicit translation locations
  validates :id, presence: { message: 'Choose a bill type' }
  validates :id, inclusion: { in: valid_ids, message: 'Choose a valid bill type' }
end
