# include this module to provide soft-delete functionality to your ActiveRecord model.
# The model must have an attribute deleted_at which defaults to nil

module SoftlyDeletable
  extend ActiveSupport::Concern
  
  included do
    scope :active, -> { where(deleted_at: nil) }
    scope :deleted, -> { where.not(deleted_at: nil) }

    # Define instance methods :before_soft_delete and :after_soft_delete if you want any methods to be
    # called before or after the soft delete of this record
    def soft_delete
      self.transaction do
        self.before_soft_delete if self.respond_to?(:before_soft_delete)
        update(deleted_at: Time.zone.now)
        self.after_soft_delete if self.respond_to?(:after_soft_delete)
      end
    end

    def active?
      self.deleted_at.nil?
    end


  end
end