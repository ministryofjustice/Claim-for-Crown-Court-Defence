class MultiFirmUserLinker
  include ActiveModel::Model

  CREDENTIAL_ERROR = 'The email or password is incorrect'.freeze

  attr_accessor :user, :email, :password

  validates :email, :password, presence: true

  # ActiveModel form objects conventionally expose a boolean-returning save method.
  # rubocop:disable-next Naming/PredicateMethod
  def save
    return false unless valid?

    linked_user = authenticated_user
    return credentials_invalid? unless linked_user

    link_saved?(linked_user)
  end

  private

  def authenticated_user
    linked_user = User.find_by(email: email.to_s.strip.downcase)
    return unless linked_user&.valid_for_authentication? { linked_user.valid_password?(password) }

    linked_user
  end

  def link_saved?(linked_user)
    link = user.multi_firm_user_links.build(linked_user:)
    return true if link.save

    link.errors.full_messages.each { |message| errors.add(:base, message) }
    false
  end

  def credentials_invalid?
    errors.add(:base, CREDENTIAL_ERROR)
    false
  end
end
