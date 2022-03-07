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
        result = if is_a?(Claim::BaseClaim)
                   update_attribute(:deleted_at, Time.zone.now)
                 else
                   update(deleted_at: Time.zone.now)
                 end
        after_soft_delete if respond_to?(:after_soft_delete)
        result
      end
    end

    def un_soft_delete
      transaction do
        before_un_soft_delete if respond_to?(:before_un_soft_delete)
        update(deleted_at: nil)
        after_un_soft_delete if respond_to?(:after_un_soft_delete)
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
