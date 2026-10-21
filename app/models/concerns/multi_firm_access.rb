module MultiFirmAccess
  extend ActiveSupport::Concern

  included do
    has_many :multi_firm_user_links, dependent: :destroy
    has_many :linked_users, through: :multi_firm_user_links
    has_one :incoming_multi_firm_user_link, class_name: 'MultiFirmUserLink',
                                            foreign_key: :linked_user_id,
                                            inverse_of: :linked_user,
                                            dependent: :destroy

    validate :linked_account_cannot_become_multi_firm_user
  end

  def selectable_multi_firm_users
    accounts = [self, *linked_users.active.enabled.includes(:persona)]
    accounts.select(&:active_for_authentication?)
  end

  private

  def linked_account_cannot_become_multi_firm_user
    return unless multi_firm_user?
    return unless incoming_multi_firm_user_link

    errors.add(:multi_firm_user, 'cannot be enabled for an account linked to another multi-firm user')
  end
end
