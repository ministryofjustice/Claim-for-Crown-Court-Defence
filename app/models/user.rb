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
#

class User < ActiveRecord::Base
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
  has_many :user_message_statuses, dependent: :destroy

  validates :first_name, :last_name, presence: true

  delegate :claims, to: :persona

  scope :advocates, -> { where(persona_type: 'Advocate') }

  def name
    [first_name, last_name] * ' '
  end

  def sortable_name
    [last_name, first_name] * ' '
  end
end
