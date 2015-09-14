# == Schema Information
#
# Table name: advocates
#
#  id              :integer          not null, primary key
#  role            :string
#  chamber_id      :integer
#  created_at      :datetime
#  updated_at      :datetime
#  supplier_number :string
#  uuid            :uuid
#

class Advocate < ActiveRecord::Base
  ROLES = %w{ admin advocate }
  include UserRoles

  belongs_to :chamber
  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  has_many :claims,  -> { includes :fee_types }, dependent: :destroy
  has_many :claims_created, dependent: :nullify, class_name: 'Claim', foreign_key: 'creator_id', inverse_of: :creator
  has_many :documents # Do not destroy - ultimately belong to chambers.

  default_scope { includes(:user, :chamber) }

  validates :user, :chamber, presence: true
  validates :chamber, presence: true
  validates :supplier_number, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[a-zA-Z0-9]{5}\z/ }

  accepts_nested_attributes_for :user

  delegate :email, to: :user
  delegate :first_name, to: :user
  delegate :last_name, to: :user
  delegate :name, to: :user



  def advocates_in_chamber
    raise "Cannot call #advocates_in_chamber on advocates who are not admins" unless self.is?('admin')
    Advocate.where('chamber_id = ? and role = ?', self.chamber_id, 'advocate').order('users.last_name')
  end


  def name_and_number
    "#{self.user.last_name}, #{self.user.first_name}: #{self.supplier_number}"
  end


end
