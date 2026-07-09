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
       agfs_permission
       lgfs_final
       lgfs_interim
       lgfs_transfer
       lgfs_hardship
       lgfs_permission].freeze
  end

  validates :id, presence: true
  validates :id, inclusion: { in: valid_ids }
end
