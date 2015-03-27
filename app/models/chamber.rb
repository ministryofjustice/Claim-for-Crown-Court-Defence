class Chamber < ActiveRecord::Base
  has_many :advocates, -> { advocates }, class_name: 'User'

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
