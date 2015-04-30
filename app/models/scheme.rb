class Scheme < ActiveRecord::Base
  has_many :claims

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
