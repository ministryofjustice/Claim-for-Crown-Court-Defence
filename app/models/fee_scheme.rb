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
  scope :version, ->(version) { where(version:) }

  def agfs?
    name.eql?('AGFS')
  end

  def lgfs?
    name.eql?('LGFS')
  end

  def lgfs_scheme_10?
    lgfs? && version.eql?(10)
  end

  def lgfs_scheme_11?
    lgfs? && version.eql?(11)
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

  def agfs_scheme_14?
    agfs? && version.eql?(14)
  end

  def agfs_scheme_15?
    agfs? && version.eql?(15)
  end

  def agfs_scheme_16?
    agfs? && version.eql?(16)
  end

  def claims
    date_range = agfs_scheme_13? ? (Settings.clar_release_date..end_date) : (start_date..end_date)

    RepresentationOrder
      .includes(defendant: { claim: { defendants: :representation_orders } })
      .where(representation_order_date: date_range)
      .map(&:claim).uniq
      .select { |claim| fee_scheme_for?(claim) }
  end

  private

  def fee_scheme_for?(claim)
    return false if (agfs? && claim.lgfs?) || (lgfs? && claim.agfs?)

    rep_order_range(claim).cover?(claim.earliest_representation_order_date)
  end

  def rep_order_range(claim)
    if claim.main_hearing_date&.after?(Settings.clair_contingency_date - 1.day)
      return (0...0) if agfs_scheme_12?
      return (Settings.clar_release_date..end_date) if agfs_scheme_13?
    end

    (start_date..end_date)
  end
end
