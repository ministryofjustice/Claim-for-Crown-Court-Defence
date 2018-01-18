# include this module to provide soft-delete functionality to your ActiveRecord model.
# The model must have an attribute deleted_at which defaults to nil

module SoftlyDeletable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(deleted_at: nil) }
    scope :softly_deleted, -> { where.not(deleted_at: nil) }

    # Define instance methods :before_soft_delete and :after_soft_delete if you want any methods to be
    # called before or after the soft delete of this record
    def soft_delete
      transaction do
        before_soft_delete if respond_to?(:before_soft_delete)
        result = update(deleted_at: Time.zone.now)
        after_soft_delete if respond_to?(:after_soft_delete)
        result
      end
    end

    def active?
      deleted_at.nil?
    end

    def softly_deleted?
      !active?
    end
  end
end
