class MultiFirmUserLink < ApplicationRecord
  belongs_to :user
  belongs_to :linked_user, class_name: 'User'

  validates :linked_user_id, uniqueness: true
  validates :user_id, uniqueness: { scope: :linked_user_id }
  validate :links_different_users
  validate :source_is_multi_firm_user
  validate :target_is_not_multi_firm_user
  validate :links_external_users
  validate :links_users_at_different_providers
  validate :source_is_not_linked_account
  validate :target_does_not_own_links

  private

  def links_different_users
    errors.add(:linked_user, 'cannot be the same as the primary account') if user_id == linked_user_id
  end

  def source_is_multi_firm_user
    return if user&.multi_firm_user?

    errors.add(:user, 'must be a multi-firm user')
  end

  def target_is_not_multi_firm_user
    return unless linked_user&.multi_firm_user?

    errors.add(:linked_user, 'cannot be a multi-firm user')
  end

  def links_external_users
    errors.add(:user, 'must be an external user') unless user&.external_user?
    errors.add(:linked_user, 'must be an external user') unless linked_user&.external_user?
  end

  def links_users_at_different_providers
    return unless user&.external_user? && linked_user&.external_user?
    return unless user.provider == linked_user.provider

    errors.add(:linked_user, 'must belong to a different provider')
  end

  def source_is_not_linked_account
    return unless self.class.where(linked_user_id: user_id).where.not(id:).exists?

    errors.add(:user, 'is already linked to another multi-firm user')
  end

  def target_does_not_own_links
    return unless self.class.where(user_id: linked_user_id).where.not(id:).exists?

    errors.add(:linked_user, 'already owns multi-firm user links')
  end
end
