class Defendant < ActiveRecord::Base
  belongs_to :claim

  validates :claim, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :maat_reference, presence: true, uniqueness: { case_sensitive: false, scope: :claim_id }

  before_save { |defendant| defendant.maat_reference = defendant.maat_reference.upcase }

  def name
    [first_name, last_name].join(' ')
  end
end
