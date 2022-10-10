class FeeScheme < ApplicationRecord
  NINE = 9
  TEN = 10
  ELEVEN = 11
  TWELVE = 12
  THIRTEEN = 13

  validates :start_date, :version, :name, presence: true

  has_many :offence_fee_schemes
  has_many :offences, through: :offence_fee_schemes

  scope :agfs, -> { where(name: 'AGFS') }
  scope :lgfs, -> { where(name: 'LGFS') }
  scope :nine, -> { where(version: FeeScheme::NINE) }
  scope :ten, -> { where(version: FeeScheme::TEN) }
  scope :eleven, -> { where(version: FeeScheme::ELEVEN) }
  scope :twelve, -> { where(version: FeeScheme::TWELVE) }
  scope :thirteen, -> { where(version: FeeScheme::THIRTEEN) }
  scope :current, -> { self.for(Time.zone.now) }
  scope :for, ->(check_date) { where(start_date: ..check_date, end_date: [nil, check_date..]) }

  def agfs?
    name.eql?('AGFS')
  end

  def lgfs?
    name.eql?('LGFS')
  end

  def lgfs_scheme_10?
    lgfs? && version.eql?(10)
  end

  def agfs_reform?
    agfs? && version >= 10
  end

  def agfs_scheme_12?
    agfs? && version.eql?(12)
  end

  def agfs_scheme_13?
    agfs? && version.eql?(13)
  end

  def self.current_agfs
    agfs.current.order(end_date: :desc).first
  end

  def self.current_lgfs
    lgfs.current.order(end_date: :desc).first
  end

  def self.for_claim(claim)
    date = claim.earliest_representation_order&.representation_order_date
    scheme = claim.agfs? ? 'AGFS' : 'LGFS'
    if date.present?
      FeeScheme.for(date).find_by(name: scheme)
    elsif claim.offence.present?
      claim.offence.fee_schemes.find_by(name: scheme)
    end
  end
end
