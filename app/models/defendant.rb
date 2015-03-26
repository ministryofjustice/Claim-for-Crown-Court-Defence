class Defendant < ActiveRecord::Base
  belongs_to :claim

  validates :claim, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
end
