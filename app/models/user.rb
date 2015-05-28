class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :persona, polymorphic: true
  has_many :messages_sent, foreign_key: 'sender_id', class_name: 'Message'

  validates :first_name, :last_name, presence: true

  delegate :claims, to: :persona

  def name
    [first_name, last_name] * ' '
  end
end
