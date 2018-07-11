class FeeScheme < ApplicationRecord
  NINE = 9
  TEN = 10
  validates :start_date, :version, :name, presence: true

  has_many :offence_fee_schemes
  has_many :offences, through: :offence_fee_schemes

  scope :agfs, -> { where(name: 'AGFS') }
  scope :lgfs, -> { where(name: 'LGFS') }
  scope :nine, -> { where(version: FeeScheme::NINE) }
  scope :ten, -> { where(version: FeeScheme::TEN) }
  scope :current, lambda {
    where('(:now BETWEEN start_date AND end_date) OR (start_date < :now AND end_date IS NULL)', now: Time.zone.now)
  }
  scope :for, lambda { |check_date|
    where('(:date BETWEEN start_date AND end_date) OR (start_date < :date AND end_date IS NULL)', date: check_date)
  }

  def self.current_agfs
    agfs.current.order(end_date: :desc).first
  end

  def self.current_lgfs
    lgfs.current.order(end_date: :desc).first
  end

  def self.for_claim(claim)
    # TODO: Align this with Fee reform SPIKE
    date = claim.earliest_representation_order&.representation_order_date
    if date.present?
      FeeScheme.for(date).find_by(name: claim.agfs? ? 'AGFS' : 'LGFS')
    elsif claim.offence.present?
      claim.offence.fee_schemes.find_by(name: claim.agfs? ? 'AGFS' : 'LGFS')
    end
  end
end
