# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  persona_id             :integer
#  persona_type           :string
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string
#  last_name              :string
#  failed_attempts        :integer          default(0), not null
#  locked_at              :datetime
#  unlock_token           :string
#  settings               :text
#  deleted_at             :datetime
#  api_key                :uuid
#

class User < ActiveRecord::Base

  include SoftlyDeletable

  auto_strip_attributes :first_name, :last_name, :email, squish: true, nullify: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise  :database_authenticatable,
          :registerable,
          :recoverable,
          :rememberable,
          :trackable,
          :validatable,
          :lockable

  belongs_to :persona, polymorphic: true
  has_many :messages_sent, foreign_key: 'sender_id', class_name: 'Message'
  has_many :user_message_statuses

  validates :first_name, :last_name, presence: true
  validates :email, confirmation: true
  attr_accessor :email_confirmation

  # enable current_user to directly call persona methods (in controllers)
  delegate :claims, to: :persona
  delegate :claims_created, to: :persona
  delegate :roles, to: :persona
  delegate :provider, to: :persona

  scope :external_users, -> { where(persona_type: 'ExternalUser') }

  def name
    [first_name, last_name] * ' '
  end

  def email_with_name
    "#{first_name} #{last_name} <#{email}>"
  end

  def sortable_name
    [last_name, first_name] * ' '
  end

  def settings
    HashWithIndifferentAccess.new(JSON.parse(read_attribute(:settings))) rescue {}
  end

  def setting?(name, default = nil)
    settings.fetch(name, default)
  end

  def save_settings!(data)
    update_attributes(settings: settings.merge(data).to_json)
  end
  alias save_setting! save_settings!

  # So we are able to return useful error messages to the user related to the locking of the account,
  # without having to disable Devise paranoid mode globally (security issues).
  #
  def unauthenticated_message
    override_paranoid_setting(false) { super }
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : 'This account has been deleted.'
  end

  def email_notification_of_message
    settings[:email_notification_of_message] || false
  end

  def send_email_notification_of_message?
    email_notification_of_message
  end

  def email_notification_of_message=(value)
    save_settings! email_notification_of_message: value.to_bool
  end

  def before_soft_delete
    self.email = "#{self.email}.deleted.#{self.id}"
  end

end
