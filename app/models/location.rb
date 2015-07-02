class Location < ActiveRecord::Base
  has_many :case_workers, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def to_s
    name
  end
end
